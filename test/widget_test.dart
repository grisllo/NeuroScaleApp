import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/providers/disclaimer_provider.dart'
    show DisclaimerAcceptedNotifier, disclaimerAcceptedProvider;
import 'package:neuroscale_app/features/auth/domain/entities/app_user.dart';
import 'package:neuroscale_app/features/auth/presentation/providers/session_provider.dart';
import 'package:neuroscale_app/main.dart';

void main() {
  testWidgets('App boots and shows disclaimer on first launch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          disclaimerAcceptedProvider.overrideWith(
            () => DisclaimerAcceptedNotifier(false),
          ),
        ],
        child: const NeuroScaleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    // DisclaimerScreen shows appTitle and accept button
    expect(find.text('NeuroScale'), findsWidgets);
    expect(find.text('Entendido, continuar'), findsOneWidget);
  });

  testWidgets(
    'App boots and shows login when disclaimer accepted but not logged in',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            disclaimerAcceptedProvider.overrideWith(
              () => DisclaimerAcceptedNotifier(true),
            ),
          ],
          child: const NeuroScaleApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsWidgets);
    },
  );

  testWidgets('App shows bottom navigation shell when logged in', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          disclaimerAcceptedProvider.overrideWith(
            () => DisclaimerAcceptedNotifier(true),
          ),
          sessionProvider.overrideWith(
            (_) => Stream.value(
              const AppUser(id: 'test-id', email: 'test@test.com'),
            ),
          ),
        ],
        child: const NeuroScaleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    // Both tab labels are visible
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Pacientes'), findsOneWidget);
  });
}
