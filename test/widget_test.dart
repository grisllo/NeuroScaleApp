import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/providers/disclaimer_provider.dart';
import 'package:neuroscale_app/main.dart';

void main() {
  testWidgets('App boots and shows disclaimer on first launch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          disclaimerAcceptedProvider.overrideWith((_) => false),
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
          disclaimerAcceptedProvider.overrideWith((_) => true),
        ],
        child: const NeuroScaleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);
  });
}
