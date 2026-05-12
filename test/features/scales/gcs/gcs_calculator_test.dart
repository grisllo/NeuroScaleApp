import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/errors/exceptions.dart';
import 'package:neuroscale_app/features/scales/gcs/domain/gcs_calculator.dart';
import 'package:neuroscale_app/features/scales/shared/domain/entities/severity.dart';

void main() {
  // Helper: valid complete answer
  Map<String, int> gcs({int eye = 4, int verbal = 5, int motor = 6}) => {
    gcsKeyEye: eye,
    gcsKeyVerbal: verbal,
    gcsKeyMotor: motor,
  };

  group('GCS — scores y severidad', () {
    test('score mínimo (3) → Grave', () {
      final result = calculateGcs(gcs(eye: 1, verbal: 1, motor: 1));
      expect(result.totalScore, 3);
      expect(result.severity, Severity.severe);
    });

    test('score 8 (techo grave) → Grave', () {
      final result = calculateGcs(gcs(eye: 2, verbal: 1, motor: 5));
      expect(result.totalScore, 8);
      expect(result.severity, Severity.severe);
    });

    test('score 9 (suelo moderado) → Moderado', () {
      final result = calculateGcs(gcs(eye: 2, verbal: 2, motor: 5));
      expect(result.totalScore, 9);
      expect(result.severity, Severity.moderate);
    });

    test('score 12 (techo moderado) → Moderado', () {
      final result = calculateGcs(gcs(eye: 3, verbal: 3, motor: 6));
      expect(result.totalScore, 12);
      expect(result.severity, Severity.moderate);
    });

    test('score 13 (suelo leve) → Leve', () {
      final result = calculateGcs(gcs(eye: 3, verbal: 4, motor: 6));
      expect(result.totalScore, 13);
      expect(result.severity, Severity.mild);
    });

    test('score máximo (15) → Leve', () {
      final result = calculateGcs(gcs(eye: 4, verbal: 5, motor: 6));
      expect(result.totalScore, 15);
      expect(result.severity, Severity.mild);
      expect(result.maxScore, 15);
    });

    test('itemScores refleja las respuestas originales', () {
      final result = calculateGcs(gcs(eye: 3, verbal: 4, motor: 5));
      expect(result.itemScores[gcsKeyEye], 3);
      expect(result.itemScores[gcsKeyVerbal], 4);
      expect(result.itemScores[gcsKeyMotor], 5);
    });
  });

  group('GCS — validación de inputs', () {
    test('eye fuera de rango inferior (0) → ValidationException', () {
      expect(
        () => calculateGcs(gcs(eye: 0)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('eye fuera de rango superior (5) → ValidationException', () {
      expect(
        () => calculateGcs(gcs(eye: 5)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('verbal fuera de rango superior (6) → ValidationException', () {
      expect(
        () => calculateGcs(gcs(verbal: 6)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('motor fuera de rango superior (7) → ValidationException', () {
      expect(
        () => calculateGcs(gcs(motor: 7)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('motor fuera de rango inferior (0) → ValidationException', () {
      expect(
        () => calculateGcs(gcs(motor: 0)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('ítem faltante (map vacío) → ValidationException', () {
      expect(() => calculateGcs({}), throwsA(isA<ValidationException>()));
    });

    test('falta solo motor → ValidationException', () {
      expect(
        () => calculateGcs({gcsKeyEye: 4, gcsKeyVerbal: 5}),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('GCS — interpretación textual', () {
    test('severity.mild tiene label "Leve"', () {
      final result = calculateGcs(gcs(eye: 4, verbal: 5, motor: 6));
      expect(result.interpretation, 'severityMild');
    });

    test('severity.moderate tiene label "Moderado"', () {
      final result = calculateGcs(gcs(eye: 2, verbal: 2, motor: 5));
      expect(result.interpretation, 'severityModerate');
    });

    test('severity.severe tiene label "Grave"', () {
      final result = calculateGcs(gcs(eye: 1, verbal: 1, motor: 1));
      expect(result.interpretation, 'severitySevere');
    });
  });
}
