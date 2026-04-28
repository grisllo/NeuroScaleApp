import '../../../../core/errors/failures.dart';
import '../../shared/domain/entities/scale_result.dart';
import '../../shared/domain/entities/severity.dart';

// Item keys
const String barthelKeyFeeding = 'feeding';
const String barthelKeyBathing = 'bathing';
const String barthelKeyGrooming = 'grooming';
const String barthelKeyDressing = 'dressing';
const String barthelKeyBowels = 'bowels';
const String barthelKeyBladder = 'bladder';
const String barthelKeyToiletUse = 'toilet_use';
const String barthelKeyTransfer = 'transfer';
const String barthelKeyMobility = 'mobility';
const String barthelKeyStairs = 'stairs';

// Allowed values per item — must be validated against this set
const _kAllowed = {
  barthelKeyFeeding: {0, 5, 10},
  barthelKeyBathing: {0, 5},
  barthelKeyGrooming: {0, 5},
  barthelKeyDressing: {0, 5, 10},
  barthelKeyBowels: {0, 5, 10},
  barthelKeyBladder: {0, 5, 10},
  barthelKeyToiletUse: {0, 5, 10},
  barthelKeyTransfer: {0, 5, 10, 15},
  barthelKeyMobility: {0, 5, 10, 15},
  barthelKeyStairs: {0, 5, 10},
};

/// Pure function — no Flutter or Supabase imports.
/// Throws [ValidationFailure] if any answer is missing or not one of the
/// allowed values for that item.
///
/// Barthel Index (Mahoney & Barthel, 1965) — 10 ítems de AVD, total 0-100.
/// Umbrales: 0-20 total, 21-60 grave, 61-90 moderada, 91-99 leve, 100 independiente.
ScaleResult calculateBarthel(Map<String, int> answers) {
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
    maxScore: 100,
    severity: severity,
    interpretation: _interpretation(total),
    itemScores: itemScores,
  );
}

int _validated(Map<String, int> answers, String key, Set<int> allowed) {
  final value = answers[key];
  if (value == null) {
    throw ValidationFailure(
      'El ítem "$key" es obligatorio en el Barthel Index.',
    );
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
  if (total == 100) return Severity.none;
  if (total >= 91) return Severity.mild;
  if (total >= 61) return Severity.moderate;
  return Severity.severe;
}

String _interpretation(int total) {
  if (total == 100) return 'Independiente';
  if (total >= 91) return 'Dependencia leve';
  if (total >= 61) return 'Dependencia moderada';
  if (total >= 21) return 'Dependencia grave';
  return 'Dependencia total';
}
