import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env/env.dart';
import 'core/providers/disclaimer_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  // Remove '#' from web URLs (skill: flutter-setup-declarative-routing)
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // En móvil/desktop las fuentes se bundlean desde el pub cache en tiempo de build.
  // En web el build no las bundlea automáticamente, así que se cargan desde CDN.
  if (!kIsWeb) GoogleFonts.config.allowRuntimeFetching = false;

  final prefs = await SharedPreferences.getInstance();
  final disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;
  final savedLocaleCode = prefs.getString(localePrefsKey) ?? 'es';
  final savedTheme = prefs.getString(themePrefsKey) ?? 'system';
  final initialTheme = switch (savedTheme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: Env.isDev,
    );
  }

  final root = ProviderScope(
    overrides: [
      disclaimerAcceptedProvider.overrideWith(
        () => DisclaimerAcceptedNotifier(disclaimerAccepted),
      ),
      localeProvider.overrideWith(
        () => LocaleNotifier(Locale(savedLocaleCode)),
      ),
      themeModeProvider.overrideWith(() => ThemeModeNotifier(initialTheme)),
    ],
    child: const NeuroScaleApp(),
  );

  if (Env.hasSentry) {
    await SentryFlutter.init((options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 0.2;
      options.environment = Env.flavor;
      // Strip PII patterns (email, DNI) from stack traces before sending.
      options.beforeSend = (event, hint) {
        final raw = event.toString();
        final hasPii =
            RegExp(
              r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
            ).hasMatch(raw) ||
            RegExp(r'\b\d{8}[A-HJ-NP-TV-Z]\b').hasMatch(raw);
        return hasPii ? null : event;
      };
    }, appRunner: () => runApp(root));
  } else {
    runApp(root);
  }
}

class NeuroScaleApp extends ConsumerWidget {
  const NeuroScaleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'NeuroScale',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
