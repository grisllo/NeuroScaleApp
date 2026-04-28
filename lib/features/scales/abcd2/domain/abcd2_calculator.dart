import '../../../../core/errors/failures.dart';
import '../../shared/domain/entities/scale_result.dart';
import '../../shared/domain/entities/severity.dart';

// Item keys
const String abcd2KeyAge = 'age';
const String abcd2KeyBp = 'bp';
const String abcd2KeyClinical = 'clinical';
const String abcd2KeyDuration = 'duration';
const String abcd2KeyDiabetes = 'diabetes';

// Allowed values per item
const _kAllowed = {
  abcd2KeyAge: {0, 1},
  abcd2KeyBp: {0, 1},
  abcd2KeyClinical: {0, 1, 2},
  abcd2KeyDuration: {0, 1, 2},
  abcd2KeyDiabetes: {0, 1},
};

/// Pure function — no Flutter or Supabase imports.
/// Throws [ValidationFailure] if any answer is missing or not one of the
/// allowed values for that item.
///
/// ABCD2 score (Johnston et al., 2007) — estratificación de riesgo de ictus
/// a 2 días tras un AIT (ataque isquémico transitorio). Total 0-7.
///   0-3 → Riesgo bajo (~1.0%)
///   4-5 → Riesgo moderado (~4.1%)
///   6-7 → Riesgo alto (~8.1%)
ScaleResult calculateAbcd2(Map<String, int> answers) {
  var total = 0;
  final itemScores = <String, int>{};

  for (final key in _kAllowed.keys) {
    final value = _validated(answers, key, _kAllowed[key]!);
    total += value;
    itemScores[key] = value;
  }

  final severity = _interpret(total);
  return ScaleResult(
    totalScore: total,
    maxScore: 7,
    severity: severity,
    interpretation: _interpretation(total),
    itemScores: itemScores,
  );
}

int _validated(Map<String, int> answers, String key, Set<int> allowed) {
  final value = answers[key];
  if (value == null) {
    throw ValidationFailure(
        'El ítem "$key" es obligatorio en la escala ABCD2.');
  }
  if (!allowed.contains(value)) {
    throw ValidationFailure(
      'El ítem "$key" solo admite los valores ${allowed.toList()..sort()} '
      '(recibido: $value).',
    );
  }
  return value;
}

Severity _interpret(int total) {
  if (total >= 6) return Severity.severe;
  if (total >= 4) return Severity.moderate;
  return Severity.mild;
}

String _interpretation(int total) {
  if (total >= 6) return 'Riesgo alto (~8.1%)';
  if (total >= 4) return 'Riesgo moderado (~4.1%)';
  return 'Riesgo bajo (~1.0%)';
}
