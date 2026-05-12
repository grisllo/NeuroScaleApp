import '../../../../core/errors/exceptions.dart';
import '../../shared/domain/entities/scale_result.dart';
import '../../shared/domain/entities/severity.dart';

const String gcsKeyEye = 'eye';
const String gcsKeyVerbal = 'verbal';
const String gcsKeyMotor = 'motor';

/// Pure function — no Flutter or Supabase imports.
/// Throws [ValidationException] if any answer is missing or out of range.
///
/// GCS thresholds (Teasdale & Jennett, 1974):
///   13–15 → Mild  |  9–12 → Moderate  |  3–8 → Severe
ScaleResult calculateGcs(Map<String, int> answers) {
  final eye = _validated(answers, gcsKeyEye, min: 1, max: 4);
  final verbal = _validated(answers, gcsKeyVerbal, min: 1, max: 5);
  final motor = _validated(answers, gcsKeyMotor, min: 1, max: 6);

  final total = eye + verbal + motor;
  final severity = _interpret(total);

  return ScaleResult(
    totalScore: total,
    maxScore: 15,
    severity: severity,
    interpretation: severity.interpretationKey,
    itemScores: {gcsKeyEye: eye, gcsKeyVerbal: verbal, gcsKeyMotor: motor},
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
      'El ítem "$key" es obligatorio en la escala GCS.',
    );
  }
  if (value < min || value > max) {
    throw ValidationException(
      'El ítem "$key" debe estar entre $min y $max (recibido: $value).',
    );
  }
  return value;
}

Severity _interpret(int total) {
  if (total >= 13) return Severity.mild;
  if (total >= 9) return Severity.moderate;
  return Severity.severe;
}
