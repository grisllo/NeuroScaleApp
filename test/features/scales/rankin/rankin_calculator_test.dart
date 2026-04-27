import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/errors/failures.dart';
import 'package:neuroscale_app/features/scales/rankin/domain/rankin_calculator.dart';
import 'package:neuroscale_app/features/scales/shared/domain/entities/severity.dart';

Map<String, int> _answers(int score) => {rankinKeyScore: score};

void main() {
  group('mRS — severidad e interpretación por grado', () {
    test('grado 0 → Severity.none / Sin síntomas', () {
      final r = calculateRankin(_answers(0));
      expect(r.severity, Severity.none);
      expect(r.interpretation, 'Sin síntomas');
      expect(r.totalScore, 0);
      expect(r.maxScore, 6);
    });

    test('grado 1 → Severity.mild / Sin discapacidad significativa', () {
      final r = calculateRankin(_answers(1));
      expect(r.severity, Severity.mild);
      expect(r.interpretation, 'Sin discapacidad significativa');
    });

    test('grado 2 → Severity.mild / Discapacidad leve', () {
      final r = calculateRankin(_answers(2));
      expect(r.severity, Severity.mild);
      expect(r.interpretation, 'Discapacidad leve');
    });

    test('grado 3 → Severity.moderate / Discapacidad moderada', () {
      final r = calculateRankin(_answers(3));
      expect(r.severity, Severity.moderate);
      expect(r.interpretation, 'Discapacidad moderada');
    });

    test('grado 4 → Severity.severe / Discapacidad moderadamente grave', () {
      final r = calculateRankin(_answers(4));
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'Discapacidad moderadamente grave');
    });

    test('grado 5 → Severity.severe / Discapacidad grave', () {
      final r = calculateRankin(_answers(5));
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'Discapacidad grave');
    });

    test('grado 6 → Severity.severe / Fallecido', () {
      final r = calculateRankin(_answers(6));
      expect(r.severity, Severity.severe);
      expect(r.interpretation, 'Fallecido');
    });
  });

  group('mRS — itemScores refleja la respuesta', () {
    test('itemScores contiene el score original', () {
      final r = calculateRankin(_answers(3));
      expect(r.itemScores[rankinKeyScore], 3);
    });
  });

  group('mRS — validación de inputs', () {
    test('score -1 → ValidationFailure', () {
      expect(
        () => calculateRankin(_answers(-1)),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('score 7 → ValidationFailure', () {
      expect(
        () => calculateRankin(_answers(7)),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('map vacío → ValidationFailure', () {
      expect(
        () => calculateRankin({}),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('clave incorrecta → ValidationFailure', () {
      expect(
        () => calculateRankin({'wrong_key': 3}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
