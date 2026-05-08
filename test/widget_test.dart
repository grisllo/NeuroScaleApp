import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/providers/disclaimer_provider.dart'
    show DisclaimerAcceptedNotifier, disclaimerAcceptedProvider;
import 'package:neuroscale_app/core/theme/app_theme.dart';
import 'package:neuroscale_app/features/auth/domain/entities/app_user.dart';
import 'package:neuroscale_app/features/auth/presentation/providers/session_provider.dart';
import 'package:neuroscale_app/features/evaluations/presentation/screens/result_screen.dart';
import 'package:neuroscale_app/features/home/presentation/screens/scales_tab_screen.dart';
import 'package:neuroscale_app/features/scales/gcs/presentation/screens/gcs_scale_screen.dart';
import 'package:neuroscale_app/features/scales/shared/domain/entities/scale_result.dart';
import 'package:neuroscale_app/features/scales/shared/domain/entities/severity.dart';
import 'package:neuroscale_app/l10n/generated/app_localizations.dart';
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

    // Navegación visible en alguna de las dos variantes (móvil: NavigationBar,
    // tablet/desktop: NavigationRail). Los tests corren a 800px → NavigationRail.
    final hasNavBar = find.byType(NavigationBar).evaluate().isNotEmpty;
    final hasNavRail = find.byType(NavigationRail).evaluate().isNotEmpty;
    expect(hasNavBar || hasNavRail, isTrue);
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Pacientes'), findsWidgets);
  });

  // ── Pantallas individuales ────────────────────────────────────────────────

  testWidgets('ResultScreen renderiza puntuación GCS y botón guardar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ResultScreen(
            result: ScaleResult(
              totalScore: 13,
              maxScore: 15,
              severity: Severity.mild,
              interpretation: 'gcsInterpMild',
              itemScores: {'eye': 4, 'verbal': 5, 'motor': 4},
            ),
            scaleTitle: 'Glasgow Coma Scale',
            scaleType: 'gcs',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('13/15'), findsOneWidget);
    expect(find.byIcon(Icons.save_outlined), findsOneWidget);
  });

  testWidgets('ResultScreen muestra el bloque de disclaimer', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ResultScreen(
            result: ScaleResult(
              totalScore: 3,
              maxScore: 15,
              severity: Severity.severe,
              interpretation: 'gcsInterpSevere',
              itemScores: {'eye': 1, 'verbal': 1, 'motor': 1},
            ),
            scaleTitle: 'GCS',
            scaleType: 'gcs',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('ScalesTabScreen renderiza las 5 tarjetas de escala', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(
            (_) =>
                Stream.value(const AppUser(id: 'u1', email: 'test@test.com')),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ScalesTabScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(5));
  });

  testWidgets('GcsScaleScreen renderiza los ítems de la escala', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GcsScaleScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    // Reset button visible en AppBar
    expect(find.byType(TextButton), findsOneWidget);
  });
}
