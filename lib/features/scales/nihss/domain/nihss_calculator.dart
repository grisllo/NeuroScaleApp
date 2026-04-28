import '../../../../core/errors/failures.dart';
import '../../shared/domain/entities/scale_result.dart';
import '../../shared/domain/entities/severity.dart';

// Item keys (15 ítems oficiales NIH/AHA)
const String nihssKey1aLoc          = 'loc';
const String nihssKey1bLocQuestions = 'loc_questions';
const String nihssKey1cLocCommands  = 'loc_commands';
const String nihssKey2Gaze          = 'gaze';
const String nihssKey3Visual        = 'visual';
const String nihssKey4Facial        = 'facial';
const String nihssKey5aMotorArmL    = 'motor_arm_left';
const String nihssKey5bMotorArmR    = 'motor_arm_right';
const String nihssKey6aMotorLegL    = 'motor_leg_left';
const String nihssKey6bMotorLegR    = 'motor_leg_right';
const String nihssKey7Ataxia        = 'ataxia';
const String nihssKey8Sensory       = 'sensory';
const String nihssKey9Language      = 'language';
const String nihssKey10Dysarthria   = 'dysarthria';
const String nihssKey11Neglect      = 'neglect';

/// Sentinel value for "Untestable" answers, per official NIH NIHSS form
/// ("9 = amputation/joint fusion" or "9 = intubated/physical barrier").
/// Excluded from the total score.
const int nihssUntestable = 9;

const Map<String, (int, int)> _kRange = {
  nihssKey1aLoc:          (0, 3),
  nihssKey1bLocQuestions: (0, 2),
  nihssKey1cLocCommands:  (0, 2),
  nihssKey2Gaze:          (0, 2),
  nihssKey3Visual:        (0, 3),
  nihssKey4Facial:        (0, 3),
  nihssKey5aMotorArmL:    (0, 4),
  nihssKey5bMotorArmR:    (0, 4),
  nihssKey6aMotorLegL:    (0, 4),
  nihssKey6bMotorLegR:    (0, 4),
  nihssKey7Ataxia:        (0, 2),
  nihssKey8Sensory:       (0, 2),
  nihssKey9Language:      (0, 3),
  nihssKey10Dysarthria:   (0, 2),
  nihssKey11Neglect:      (0, 2),
};

const Set<String> _kAllowsUntestable = {
  nihssKey5aMotorArmL,
  nihssKey5bMotorArmR,
  nihssKey6aMotorLegL,
  nihssKey6bMotorLegR,
  nihssKey7Ataxia,
  nihssKey10Dysarthria,
};

/// Pure function — no Flutter or Supabase imports.
/// Throws [ValidationFailure] if any answer is missing or out of range.
///
/// NIHSS (Brott et al., 1989; AHA/ASA NIHSS instructions). Total 0-42.
/// Items 5a/5b/6a/6b/7/10 accept the untestable code 9, which is recorded
/// in itemScores but excluded from totalScore (per official NIH form).
///
/// Severity bands:
///   0     → Sin déficit
///   1-4   → Ictus menor
///   5-15  → Ictus moderado
///   16-20 → Ictus moderado a grave
///   21-42 → Ictus grave
ScaleResult calculateNihss(Map<String, int> answers) {
  var total = 0;
  final itemScores = <String, int>{};

  for (final entry in _kRange.entries) {
    final key = entry.key;
    final range = entry.value;
    final value = _validated(answers, key, range.$1, range.$2);
    itemScores[key] = value;
    if (value != nihssUntestable) {
      total += value;
    }
  }

  return ScaleResult(
    totalScore: total,
    maxScore: 42,
    severity: _interpretSeverity(total),
    interpretation: _interpretText(total),
    itemScores: itemScores,
  );
}

int _validated(Map<String, int> answers, String key, int min, int max) {
  final value = answers[key];
  if (value == null) {
    throw ValidationFailure('El ítem "$key" es obligatorio en la escala NIHSS.');
  }
  if (value == nihssUntestable && _kAllowsUntestable.contains(key)) {
    return value;
  }
  if (value < min || value > max) {
    final allowsUn = _kAllowsUntestable.contains(key);
    final hint = allowsUn ? ' o $nihssUntestable (no evaluable)' : '';
    throw ValidationFailure(
      'El ítem "$key" debe estar entre $min y $max$hint (recibido: $value).',
    );
  }
  return value;
}

Severity _interpretSeverity(int total) {
  if (total == 0) return Severity.none;
  if (total <= 4) return Severity.mild;
  if (total <= 20) return Severity.moderate;
  return Severity.severe;
}

String _interpretText(int total) {
  if (total == 0) return 'Sin déficit';
  if (total <= 4) return 'Ictus menor (1-4)';
  if (total <= 15) return 'Ictus moderado (5-15)';
  if (total <= 20) return 'Ictus moderado a grave (16-20)';
  return 'Ictus grave (21-42)';
}
