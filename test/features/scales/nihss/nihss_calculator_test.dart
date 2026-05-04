import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/scales/nihss/domain/nihss_calculator.dart';
import 'package:neuroscale_app/features/scales/shared/domain/entities/severity.dart';

Map<String, int> _allZero() => {
  nihssKey1aLoc: 0,
  nihssKey1bLocQuestions: 0,
  nihssKey1cLocCommands: 0,
  nihssKey2Gaze: 0,
  nihssKey3Visual: 0,
  nihssKey4Facial: 0,
  nihssKey5aMotorArmL: 0,
  nihssKey5bMotorArmR: 0,
  nihssKey6aMotorLegL: 0,
  nihssKey6bMotorLegR: 0,
  nihssKey7Ataxia: 0,
  nihssKey8Sensory: 0,
  nihssKey9Language: 0,
  nihssKey10Dysarthria: 0,
  nihssKey11Neglect: 0,
};

Map<String, int> _allMax() => {
  nihssKey1aLoc: 3,
  nihssKey1bLocQuestions: 2,
  nihssKey1cLocCommands: 2,
  nihssKey2Gaze: 2,
  nihssKey3Visual: 3,
  nihssKey4Facial: 3,
  nihssKey5aMotorArmL: 4,
  nihssKey5bMotorArmR: 4,
  nihssKey6aMotorLegL: 4,
  nihssKey6bMotorLegR: 4,
  nihssKey7Ataxia: 2,
  nihssKey8Sensory: 2,
  nihssKey9Language: 3,
  nihssKey10Dysarthria: 2,
  nihssKey11Neglect: 2,
};

void main() {
  group('NIHSS — bordes absolutos', () {
    test('total 0 (todo cero) → Severity.none / Sin déficit', () {
      final r = calculateNihss(_allZero());
      expect(r.totalScore, 0);
      expect(r.maxScore, 42);
      expect(r.severity, Severity.none);
      expect(r.interpretation, 'nihssInterp0');
    });

    test('total 42 (todo máximo) → Severity.severe / Ictus grave', () {
      final r = calculateNihss(_allMax());
      expect(r.totalScore, 42);
      expect(r.maxScore, 42);
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'nihssInterpSevere');
    });
  });

  group('NIHSS — umbrales 0/1, 4/5, 15/16, 20/21', () {
    test('total 1 → mild / Ictus menor', () {
      final r = calculateNihss({..._allZero(), nihssKey1aLoc: 1});
      expect(r.totalScore, 1);
      expect(r.severity, Severity.mild);
      expect(r.interpretation, 'nihssInterpMinor');
    });

    test('total 4 (techo mild) → mild / Ictus menor', () {
      final r = calculateNihss({
        ..._allZero(),
        nihssKey1aLoc: 3,
        nihssKey1bLocQuestions: 1,
      }); // 3+1
      expect(r.totalScore, 4);
      expect(r.severity, Severity.mild);
      expect(r.interpretation, 'nihssInterpMinor');
    });

    test('total 5 (suelo moderate) → moderate / Ictus moderado (5-15)', () {
      final r = calculateNihss({
        ..._allZero(),
        nihssKey1aLoc: 3,
        nihssKey1bLocQuestions: 2,
      }); // 3+2
      expect(r.totalScore, 5);
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'nihssInterpModerate');
    });

    test('total 15 (techo moderado) → moderate / Ictus moderado (5-15)', () {
      final r = calculateNihss({
        ..._allZero(),
        nihssKey1aLoc: 3,
        nihssKey1bLocQuestions: 2,
        nihssKey1cLocCommands: 2,
        nihssKey2Gaze: 2,
        nihssKey3Visual: 3,
        nihssKey4Facial: 3,
      }); // 3+2+2+2+3+3 = 15
      expect(r.totalScore, 15);
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'nihssInterpModerate');
    });

    test(
      'total 16 (suelo moderado-grave) → moderate / Ictus moderado a grave',
      () {
        final r = calculateNihss({
          ..._allZero(),
          nihssKey1aLoc: 3,
          nihssKey1bLocQuestions: 2,
          nihssKey1cLocCommands: 2,
          nihssKey2Gaze: 2,
          nihssKey3Visual: 3,
          nihssKey4Facial: 3,
          nihssKey8Sensory: 1,
        }); // 15+1 = 16
        expect(r.totalScore, 16);
        expect(r.severity, Severity.moderate);
        expect(r.interpretation, 'nihssInterpModerateSevere');
      },
    );

    test(
      'total 20 (techo moderado-grave) → moderate / Ictus moderado a grave',
      () {
        final r = calculateNihss({
          ..._allZero(),
          nihssKey1aLoc: 3,
          nihssKey1bLocQuestions: 2,
          nihssKey1cLocCommands: 2,
          nihssKey2Gaze: 2,
          nihssKey3Visual: 3,
          nihssKey4Facial: 3,
          nihssKey5aMotorArmL: 4,
          nihssKey7Ataxia: 1,
        }); // 15+4+1 = 20
        expect(r.totalScore, 20);
        expect(r.severity, Severity.moderate);
        expect(r.interpretation, 'nihssInterpModerateSevere');
      },
    );

    test('total 21 (suelo severe) → severe / Ictus grave', () {
      final r = calculateNihss({
        ..._allZero(),
        nihssKey1aLoc: 3,
        nihssKey1bLocQuestions: 2,
        nihssKey1cLocCommands: 2,
        nihssKey2Gaze: 2,
        nihssKey3Visual: 3,
        nihssKey4Facial: 3,
        nihssKey5aMotorArmL: 4,
        nihssKey7Ataxia: 2,
      }); // 15+4+2 = 21
      expect(r.totalScore, 21);
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'nihssInterpSevere');
    });
  });

  group('NIHSS — Untestable (UN=9) excluido del total', () {
    test('UN aislado en 5a (resto 0) → total 0 / none', () {
      final r = calculateNihss({
        ..._allZero(),
        nihssKey5aMotorArmL: nihssUntestable,
      });
      expect(r.totalScore, 0);
      expect(r.severity, Severity.none);
      expect(r.itemScores[nihssKey5aMotorArmL], nihssUntestable);
    });

    test('los 6 ítems UN-elegibles a 9 + resto 0 → total 0 / none', () {
      final r = calculateNihss({
        ..._allZero(),
        nihssKey5aMotorArmL: nihssUntestable,
        nihssKey5bMotorArmR: nihssUntestable,
        nihssKey6aMotorLegL: nihssUntestable,
        nihssKey6bMotorLegR: nihssUntestable,
        nihssKey7Ataxia: nihssUntestable,
        nihssKey10Dysarthria: nihssUntestable,
      });
      expect(r.totalScore, 0);
      expect(r.severity, Severity.none);
      // itemScores conserva el sentinel
      expect(r.itemScores[nihssKey5aMotorArmL], nihssUntestable);
      expect(r.itemScores[nihssKey10Dysarthria], nihssUntestable);
    });

    test('todos UN-elegibles a 9 + resto al máximo → total 22', () {
      // Max total 42 menos los UN-elegibles (4+4+4+4+2+2 = 20) = 22
      final r = calculateNihss({
        ..._allMax(),
        nihssKey5aMotorArmL: nihssUntestable,
        nihssKey5bMotorArmR: nihssUntestable,
        nihssKey6aMotorLegL: nihssUntestable,
        nihssKey6bMotorLegR: nihssUntestable,
        nihssKey7Ataxia: nihssUntestable,
        nihssKey10Dysarthria: nihssUntestable,
      });
      expect(r.totalScore, 22);
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'nihssInterpSevere');
    });

    test('UN en 7 + resto generador de severo → total intacto', () {
      final r = calculateNihss({
        ..._allZero(),
        nihssKey1aLoc: 3,
        nihssKey1bLocQuestions: 2,
        nihssKey1cLocCommands: 2,
        nihssKey2Gaze: 2,
        nihssKey3Visual: 3,
        nihssKey4Facial: 3,
        nihssKey5aMotorArmL: 4,
        nihssKey7Ataxia: nihssUntestable, // antes 2 → ahora UN, sin contribuir
      });
      expect(r.totalScore, 19); // 21 - 2 (ataxia ahora UN)
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'nihssInterpModerateSevere');
    });
  });

  group('NIHSS — itemScores', () {
    test('itemScores refleja todas las respuestas (incluye UN)', () {
      final answers = {..._allMax(), nihssKey5aMotorArmL: nihssUntestable};
      final r = calculateNihss(answers);
      expect(r.itemScores.length, 15);
      for (final key in answers.keys) {
        expect(r.itemScores[key], answers[key], reason: 'mismatch en $key');
      }
    });
  });

  group('NIHSS — validación: ítem ausente', () {
    test('map vacío → ValidationFailure', () {
      expect(() => calculateNihss({}), throwsA(isA<ValidationFailure>()));
    });

    test('falta 1a → ValidationFailure', () {
      final incomplete = Map<String, int>.from(_allZero())
        ..remove(nihssKey1aLoc);
      expect(
        () => calculateNihss(incomplete),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('falta 11 (negligencia) → ValidationFailure', () {
      final incomplete = Map<String, int>.from(_allZero())
        ..remove(nihssKey11Neglect);
      expect(
        () => calculateNihss(incomplete),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('NIHSS — validación: rango fuera de límites', () {
    test('1a=-1 → ValidationFailure', () {
      expect(
        () => calculateNihss({..._allZero(), nihssKey1aLoc: -1}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('1a=4 → ValidationFailure (máximo es 3)', () {
      expect(
        () => calculateNihss({..._allZero(), nihssKey1aLoc: 4}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('motor brazo izquierdo=5 → ValidationFailure (máximo es 4)', () {
      expect(
        () => calculateNihss({..._allZero(), nihssKey5aMotorArmL: 5}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('ataxia=3 → ValidationFailure (máximo es 2)', () {
      expect(
        () => calculateNihss({..._allZero(), nihssKey7Ataxia: 3}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('lenguaje=4 → ValidationFailure (máximo es 3)', () {
      expect(
        () => calculateNihss({..._allZero(), nihssKey9Language: 4}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('NIHSS — validación: UN en ítems no permitidos', () {
    test('1a=9 → ValidationFailure (LOC no permite UN)', () {
      expect(
        () => calculateNihss({..._allZero(), nihssKey1aLoc: nihssUntestable}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('sensibilidad=9 → ValidationFailure (8 no permite UN)', () {
      expect(
        () =>
            calculateNihss({..._allZero(), nihssKey8Sensory: nihssUntestable}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('lenguaje=9 → ValidationFailure (9 no permite UN)', () {
      expect(
        () =>
            calculateNihss({..._allZero(), nihssKey9Language: nihssUntestable}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('negligencia=9 → ValidationFailure (11 no permite UN)', () {
      expect(
        () =>
            calculateNihss({..._allZero(), nihssKey11Neglect: nihssUntestable}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('NIHSS — invariante puro', () {
    test('mismo input → mismo output (sin estado)', () {
      final input = {..._allMax(), nihssKey5aMotorArmL: nihssUntestable};
      final r1 = calculateNihss(input);
      final r2 = calculateNihss(input);
      expect(r1.totalScore, r2.totalScore);
      expect(r1.severity, r2.severity);
      expect(r1.interpretation, r2.interpretation);
      expect(r1.itemScores, r2.itemScores);
    });
  });
}
