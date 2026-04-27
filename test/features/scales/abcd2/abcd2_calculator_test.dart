import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/scales/abcd2/domain/abcd2_calculator.dart';
import 'package:neuroscale_app/features/scales/shared/domain/entities/severity.dart';

Map<String, int> _min() => {
      abcd2KeyAge: 0,
      abcd2KeyBp: 0,
      abcd2KeyClinical: 0,
      abcd2KeyDuration: 0,
      abcd2KeyDiabetes: 0,
    };

Map<String, int> _max() => {
      abcd2KeyAge: 1,
      abcd2KeyBp: 1,
      abcd2KeyClinical: 2,
      abcd2KeyDuration: 2,
      abcd2KeyDiabetes: 1,
    };

void main() {
  group('ABCD2 — bordes absolutos', () {
    test('total 0 (todo mínimo) → Severity.mild / Riesgo bajo', () {
      final r = calculateAbcd2(_min());
      expect(r.totalScore, 0);
      expect(r.maxScore, 7);
      expect(r.severity, Severity.mild);
      expect(r.interpretation, 'Riesgo bajo (~1.0%)');
    });

    test('total 7 (todo máximo) → Severity.severe / Riesgo alto', () {
      final r = calculateAbcd2(_max());
      expect(r.totalScore, 7);
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'Riesgo alto (~8.1%)');
    });
  });

  group('ABCD2 — umbrales 3/4 y 5/6', () {
    test('total 3 → Riesgo bajo (techo mild)', () {
      final r = calculateAbcd2({
        abcd2KeyAge: 1,
        abcd2KeyBp: 1,
        abcd2KeyClinical: 1,
        abcd2KeyDuration: 0,
        abcd2KeyDiabetes: 0,
      }); // 1+1+1 = 3
      expect(r.totalScore, 3);
      expect(r.severity, Severity.mild);
      expect(r.interpretation, 'Riesgo bajo (~1.0%)');
    });

    test('total 4 → Riesgo moderado (suelo moderate)', () {
      final r = calculateAbcd2({
        abcd2KeyAge: 1,
        abcd2KeyBp: 1,
        abcd2KeyClinical: 1,
        abcd2KeyDuration: 1,
        abcd2KeyDiabetes: 0,
      }); // 1+1+1+1 = 4
      expect(r.totalScore, 4);
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'Riesgo moderado (~4.1%)');
    });

    test('total 5 → Riesgo moderado (techo moderate)', () {
      final r = calculateAbcd2({
        abcd2KeyAge: 1,
        abcd2KeyBp: 1,
        abcd2KeyClinical: 2,
        abcd2KeyDuration: 1,
        abcd2KeyDiabetes: 0,
      }); // 1+1+2+1 = 5
      expect(r.totalScore, 5);
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'Riesgo moderado (~4.1%)');
    });

    test('total 6 → Riesgo alto (suelo severe)', () {
      final r = calculateAbcd2({
        abcd2KeyAge: 1,
        abcd2KeyBp: 1,
        abcd2KeyClinical: 2,
        abcd2KeyDuration: 2,
        abcd2KeyDiabetes: 0,
      }); // 1+1+2+2 = 6
      expect(r.totalScore, 6);
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'Riesgo alto (~8.1%)');
    });
  });

  group('ABCD2 — itemScores', () {
    test('itemScores refleja todas las respuestas', () {
      final answers = _max();
      final r = calculateAbcd2(answers);
      for (final key in answers.keys) {
        expect(r.itemScores[key], answers[key]);
      }
    });
  });

  group('ABCD2 — validación: valores no permitidos', () {
    test('age=2 → ValidationFailure (solo 0/1)', () {
      expect(
        () => calculateAbcd2({..._min(), abcd2KeyAge: 2}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('bp=-1 → ValidationFailure', () {
      expect(
        () => calculateAbcd2({..._min(), abcd2KeyBp: -1}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('clinical=3 → ValidationFailure (máximo es 2)', () {
      expect(
        () => calculateAbcd2({..._min(), abcd2KeyClinical: 3}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('duration=5 → ValidationFailure (solo 0/1/2)', () {
      expect(
        () => calculateAbcd2({..._min(), abcd2KeyDuration: 5}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('diabetes=2 → ValidationFailure (solo 0/1)', () {
      expect(
        () => calculateAbcd2({..._min(), abcd2KeyDiabetes: 2}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('ABCD2 — validación: ítem ausente', () {
    test('map vacío → ValidationFailure', () {
      expect(
        () => calculateAbcd2({}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('falta clinical → ValidationFailure', () {
      final incomplete = Map<String, int>.from(_min())
        ..remove(abcd2KeyClinical);
      expect(
        () => calculateAbcd2(incomplete),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('falta duration → ValidationFailure', () {
      final incomplete = Map<String, int>.from(_min())
        ..remove(abcd2KeyDuration);
      expect(
        () => calculateAbcd2(incomplete),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
