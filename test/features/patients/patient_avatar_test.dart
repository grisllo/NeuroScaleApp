import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/features/patients/domain/entities/patient.dart';
import 'package:neuroscale_app/features/patients/presentation/widgets/patient_avatar.dart';

Patient _patient(String alias) => Patient(
  id: 'test-id',
  userId: 'u1',
  alias: alias,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Widget _wrap(String alias, {double radius = 22}) => MaterialApp(
  home: Scaffold(
    body: PatientAvatar(patient: _patient(alias), radius: radius),
  ),
);

void main() {
  group('PatientAvatar — iniciales', () {
    testWidgets('alias multi-palabra → primeras letras de cada palabra', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap('Juan García'));
      await tester.pumpAndSettle();
      expect(find.text('JG'), findsOneWidget);
    });

    testWidgets(
      'alias mixto letra+número (P001) → primera letra + último dígito',
      (tester) async {
        await tester.pumpWidget(_wrap('P001'));
        await tester.pumpAndSettle();
        expect(find.text('P1'), findsOneWidget);
      },
    );

    testWidgets('alias mixto (P002) → P2', (tester) async {
      await tester.pumpWidget(_wrap('P002'));
      await tester.pumpAndSettle();
      expect(find.text('P2'), findsOneWidget);
    });

    testWidgets('alias solo dígitos → últimos 2 dígitos', (tester) async {
      await tester.pumpWidget(_wrap('042'));
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('alias solo letras → primeros 2 en mayúsculas', (tester) async {
      await tester.pumpWidget(_wrap('Ana'));
      await tester.pumpAndSettle();
      expect(find.text('AN'), findsOneWidget);
    });

    testWidgets('alias vacío → ?', (tester) async {
      await tester.pumpWidget(_wrap(''));
      await tester.pumpAndSettle();
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('alias tres palabras → primeras letras de las dos primeras', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap('María José Pérez'));
      await tester.pumpAndSettle();
      expect(find.text('MJ'), findsOneWidget);
    });

    testWidgets('Semantics label = patient.alias', (tester) async {
      await tester.pumpWidget(_wrap('Caso A'));
      await tester.pumpAndSettle();
      final semantics = tester.getSemantics(find.byType(PatientAvatar));
      expect(semantics.label, 'Caso A');
    });
  });
}
