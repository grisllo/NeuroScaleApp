import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/scales/barthel/domain/barthel_calculator.dart';
import 'package:neuroscale_app/features/scales/shared/domain/entities/severity.dart';

// Máximo posible por ítem
Map<String, int> _maxAnswers() => {
  barthelKeyFeeding: 10,
  barthelKeyBathing: 5,
  barthelKeyGrooming: 5,
  barthelKeyDressing: 10,
  barthelKeyBowels: 10,
  barthelKeyBladder: 10,
  barthelKeyToiletUse: 10,
  barthelKeyTransfer: 15,
  barthelKeyMobility: 15,
  barthelKeyStairs: 10,
};

// Mínimo posible por ítem
Map<String, int> _minAnswers() => {
  barthelKeyFeeding: 0,
  barthelKeyBathing: 0,
  barthelKeyGrooming: 0,
  barthelKeyDressing: 0,
  barthelKeyBowels: 0,
  barthelKeyBladder: 0,
  barthelKeyToiletUse: 0,
  barthelKeyTransfer: 0,
  barthelKeyMobility: 0,
  barthelKeyStairs: 0,
};

// Construye respuestas que sumen un total dado ajustando feeding y transfer
Map<String, int> _withTotal(int total) {
  // Distribución: transfer=15, mobility=15, el resto a 0, feeding y bathing ajustan
  // Usamos el mínimo y luego subimos feeding (0/5/10) y transfer (0/5/10/15) para cubrir umbrales
  final base = _minAnswers();
  // Sumas posibles rápidas:  transfer(15) + mobility(15) = 30 ya cubre rangos altos
  // Para umbrales específicos, ajustamos manualmente
  switch (total) {
    case 0:
      return _minAnswers();
    case 20:
      return {...base, barthelKeyTransfer: 15, barthelKeyMobility: 5};
    case 21:
      return {
        ...base,
        barthelKeyTransfer: 15,
        barthelKeyMobility: 5,
        barthelKeyBathing: 1 == 0 ? 0 : 5,
      };
    case 60:
      return {
        ...base,
        barthelKeyFeeding: 10,
        barthelKeyBathing: 5,
        barthelKeyGrooming: 5,
        barthelKeyDressing: 10,
        barthelKeyBowels: 0,
        barthelKeyBladder: 0,
        barthelKeyToiletUse: 0,
        barthelKeyTransfer: 15,
        barthelKeyMobility: 15,
        barthelKeyStairs: 0,
      }; // 10+5+5+10+15+15 = 60
    case 61:
      return {
        ...base,
        barthelKeyFeeding: 10,
        barthelKeyBathing: 5,
        barthelKeyGrooming: 5,
        barthelKeyDressing: 10,
        barthelKeyBowels: 0,
        barthelKeyBladder: 0,
        barthelKeyToiletUse: 0,
        barthelKeyTransfer: 15,
        barthelKeyMobility: 15,
        barthelKeyStairs: 1 == 0 ? 0 : 5,
      }; // 10+5+5+10+15+15+5 = 65 → usamos 61 aproximando
    case 90:
      return {
        ...base,
        barthelKeyFeeding: 10,
        barthelKeyBathing: 5,
        barthelKeyGrooming: 5,
        barthelKeyDressing: 10,
        barthelKeyBowels: 10,
        barthelKeyBladder: 10,
        barthelKeyToiletUse: 10,
        barthelKeyTransfer: 15,
        barthelKeyMobility: 15,
        barthelKeyStairs: 0,
      }; // 90
    case 91:
      return {
        ...base,
        barthelKeyFeeding: 10,
        barthelKeyBathing: 5,
        barthelKeyGrooming: 5,
        barthelKeyDressing: 10,
        barthelKeyBowels: 10,
        barthelKeyBladder: 10,
        barthelKeyToiletUse: 10,
        barthelKeyTransfer: 15,
        barthelKeyMobility: 15,
        barthelKeyStairs: 5,
      }; // 95 → closest allowed ≥91
    case 99:
      return {
        ...base,
        barthelKeyFeeding: 10,
        barthelKeyBathing: 5,
        barthelKeyGrooming: 5,
        barthelKeyDressing: 10,
        barthelKeyBowels: 10,
        barthelKeyBladder: 10,
        barthelKeyToiletUse: 10,
        barthelKeyTransfer: 15,
        barthelKeyMobility: 15,
        barthelKeyStairs: 5,
      }; // 95 — no hay combinación que sume exactamente 99 con los pesos; cubierto por 95
    case 100:
      return _maxAnswers();
    default:
      return _minAnswers();
  }
}

void main() {
  group('Barthel — bordes absolutos', () {
    test('total 0 → Severity.severe / Dependencia total', () {
      final r = calculateBarthel(_minAnswers());
      expect(r.totalScore, 0);
      expect(r.maxScore, 100);
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'barthelInterpTotal');
    });

    test('total 100 → Severity.none / Independiente', () {
      final r = calculateBarthel(_maxAnswers());
      expect(r.totalScore, 100);
      expect(r.severity, Severity.none);
      expect(r.interpretation, 'barthelInterpIndependent');
    });
  });

  group('Barthel — umbrales de severidad', () {
    test('total 20 → Dependencia total (techo severe-total)', () {
      final r = calculateBarthel(_withTotal(20));
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'barthelInterpTotal');
    });

    test('total 21+ → Dependencia grave (suelo severe-grave)', () {
      final r = calculateBarthel({
        ..._minAnswers(),
        barthelKeyTransfer: 15,
        barthelKeyMobility: 10,
      }); // 25
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'barthelInterpSevere');
    });

    test('total 60 → Dependencia grave (techo severe-grave)', () {
      final r = calculateBarthel(_withTotal(60));
      expect(r.totalScore, 60);
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'barthelInterpSevere');
    });

    test('total 65 → Dependencia moderada (suelo moderate)', () {
      final r = calculateBarthel(_withTotal(61));
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'barthelInterpModerate');
    });

    test('total 90 → Dependencia moderada (techo moderate)', () {
      final r = calculateBarthel(_withTotal(90));
      expect(r.totalScore, 90);
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'barthelInterpModerate');
    });

    test('total 95 → Dependencia leve (suelo mild)', () {
      final r = calculateBarthel(_withTotal(91));
      expect(r.severity, Severity.mild);
      expect(r.interpretation, 'barthelInterpMild');
    });
  });

  group('Barthel — itemScores', () {
    test('itemScores refleja todas las respuestas', () {
      final answers = _maxAnswers();
      final r = calculateBarthel(answers);
      for (final key in answers.keys) {
        expect(r.itemScores[key], answers[key]);
      }
    });
  });

  group('Barthel — validación: valores no permitidos', () {
    test('feeding=3 → ValidationFailure (solo 0/5/10)', () {
      expect(
        () => calculateBarthel({..._minAnswers(), barthelKeyFeeding: 3}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('bathing=3 → ValidationFailure (solo 0/5)', () {
      expect(
        () => calculateBarthel({..._minAnswers(), barthelKeyBathing: 3}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('transfer=7 → ValidationFailure (solo 0/5/10/15)', () {
      expect(
        () => calculateBarthel({..._minAnswers(), barthelKeyTransfer: 7}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('mobility=-1 → ValidationFailure', () {
      expect(
        () => calculateBarthel({..._minAnswers(), barthelKeyMobility: -1}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('stairs=20 → ValidationFailure (máximo es 10)', () {
      expect(
        () => calculateBarthel({..._minAnswers(), barthelKeyStairs: 20}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('Barthel — validación: ítem ausente', () {
    test('map vacío → ValidationFailure', () {
      expect(() => calculateBarthel({}), throwsA(isA<ValidationFailure>()));
    });

    test('falta mobility → ValidationFailure', () {
      final incomplete = Map<String, int>.from(_minAnswers())
        ..remove(barthelKeyMobility);
      expect(
        () => calculateBarthel(incomplete),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
