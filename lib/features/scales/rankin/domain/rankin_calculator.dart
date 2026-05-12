import '../../../../core/errors/exceptions.dart';
import '../../shared/domain/entities/scale_result.dart';
import '../../shared/domain/entities/severity.dart';

const String rankinKeyScore = 'score';

/// Pure function — no Flutter or Supabase imports.
/// Throws [ValidationException] if the answer is missing or out of range.
///
/// mRS (Modified Rankin Scale) — Rankin 1957, modified by van Swieten et al. 1988.
/// Grades 0-6, where 6 = death. Standard neurological disability scale post-stroke.
ScaleResult calculateRankin(Map<String, int> answers) {
  final score = _validated(answers, rankinKeyScore, min: 0, max: 6);
  final severity = _interpret(score);

  return ScaleResult(
    totalScore: score,
    maxScore: 6,
    severity: severity,
    interpretation: _interpretationKey(score),
    itemScores: {rankinKeyScore: score},
  );
}

int _validated(
  Map<String, int> answers,
  String key, {
  required int min,
  required int max,
}) {
  final value = answers[key];
  if (value == null) {
    throw ValidationException(
      'El ítem "$key" es obligatorio en la escala mRS.',
    );
  }
  if (value < min || value > max) {
    throw ValidationException(
      'El ítem "$key" debe estar entre $min y $max (recibido: $value).',
    );
  }
  return value;
}

Severity _interpret(int score) => switch (score) {
  0 => Severity.none,
  1 || 2 => Severity.mild,
  3 => Severity.moderate,
  _ => Severity.severe,
};

String _interpretationKey(int score) => switch (score) {
  0 => 'rankinInterp0',
  1 => 'rankinInterp1',
  2 => 'rankinInterp2',
  3 => 'rankinInterp3',
  4 => 'rankinInterp4',
  5 => 'rankinInterp5',
  _ => 'rankinInterp6',
};
