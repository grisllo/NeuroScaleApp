import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/theme/app_theme.dart';
import 'package:neuroscale_app/features/auth/domain/entities/app_user.dart';
import 'package:neuroscale_app/features/auth/presentation/providers/session_provider.dart';
import 'package:neuroscale_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:neuroscale_app/l10n/generated/app_localizations.dart';

Widget _wrap({AppUser? user}) => ProviderScope(
  overrides: [sessionProvider.overrideWith((_) => Stream.value(user))],
  child: MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const ProfileScreen(),
  ),
);

void main() {
  group('ProfileScreen — smoke tests', () {
    testWidgets('muestra email del usuario cuando tiene sesión', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          user: const AppUser(id: 'u1', email: 'test@test.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('test@test.com'), findsOneWidget);
    });

    testWidgets('muestra botones de preferencias (tema e idioma)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          user: const AppUser(id: 'u1', email: 'test@test.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('muestra botón de cerrar sesión', (tester) async {
      await tester.pumpWidget(
        _wrap(
          user: const AppUser(id: 'u1', email: 'test@test.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('muestra sección peligrosa con botón de borrar cuenta', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          user: const AppUser(id: 'u1', email: 'test@test.com'),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll hasta el final para que el botón de borrar sea visible.
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);
    });

    testWidgets('muestra dash cuando no hay sesión activa', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('—'), findsOneWidget);
    });
  });
}
