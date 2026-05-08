import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/utils/pii_detector.dart';

void main() {
  group('PiiDetector — true positives', () {
    test('detecta DNI español con letra mayúscula', () {
      final matches = PiiDetector.detect('Paciente con DNI 12345678A');
      expect(matches, hasLength(1));
      expect(matches.first.kind, PiiKind.dni);
      expect(matches.first.snippet, '12345678A');
    });

    test('detecta DNI con letra minúscula (case-insensitive)', () {
      expect(PiiDetector.hasAny('12345678a'), isTrue);
    });

    test('detecta NIE empezando por X', () {
      final matches = PiiDetector.detect('NIE: X1234567A');
      expect(matches, hasLength(1));
      expect(matches.first.kind, PiiKind.nie);
    });

    test('detecta email', () {
      final matches = PiiDetector.detect('contacto: user@example.com');
      expect(matches.single.kind, PiiKind.email);
    });

    test('detecta teléfono móvil ES (9 dígitos, empieza por 6)', () {
      expect(PiiDetector.hasAny('Tel 612345678'), isTrue);
    });

    test('detecta fecha con barras', () {
      expect(PiiDetector.hasAny('Nacido el 01/01/1980'), isTrue);
    });

    test('detecta fecha con guiones y año 20xx', () {
      expect(PiiDetector.hasAny('Ingresó el 1-1-2000'), isTrue);
    });

    test('detecta fecha con puntos', () {
      expect(PiiDetector.hasAny('Fecha: 12.12.1990'), isTrue);
    });

    test('detecta múltiples PII de distintos tipos en mismo string', () {
      final matches = PiiDetector.detect(
        'Juan García, DNI 12345678A, tel 612345678',
      );
      final kinds = matches.map((e) => e.kind).toSet();
      expect(kinds, containsAll([PiiKind.dni, PiiKind.phone]));
    });
  });

  group('PiiDetector — false positives evitados', () {
    test('código de paciente P-001 NO matchea', () {
      expect(PiiDetector.hasAny('Caso P-001'), isFalse);
    });

    test('edad "65 años" NO matchea', () {
      expect(PiiDetector.hasAny('varón de 65 años'), isFalse);
    });

    test('número de caso "Caso 24" NO matchea', () {
      expect(PiiDetector.hasAny('Caso 24, ictus isquémico'), isFalse);
    });

    test('fecha relativa "hace 3 días" NO matchea', () {
      expect(PiiDetector.hasAny('hace 3 días llegó al hospital'), isFalse);
    });

    test('siglas médicas TBI/GCS NO matchean', () {
      expect(PiiDetector.hasAny('TBI severo, GCS 8'), isFalse);
    });

    test('descripción anonimizada típica NO matchea', () {
      expect(
        PiiDetector.hasAny('varón, 65 años, TCE por caída desde escalera'),
        isFalse,
      );
    });

    test('fecha con año de 2 dígitos NO matchea (ambigua)', () {
      expect(PiiDetector.hasAny('Fecha 1-1-80'), isFalse);
    });
  });

  group('PiiDetector — bordes', () {
    test('string vacío devuelve lista vacía y hasAny=false', () {
      expect(PiiDetector.detect(''), isEmpty);
      expect(PiiDetector.hasAny(''), isFalse);
    });

    test('string solo con espacios NO matchea', () {
      expect(PiiDetector.hasAny('     '), isFalse);
    });
  });
}
