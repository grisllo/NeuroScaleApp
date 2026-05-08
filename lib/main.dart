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
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  // Remove '#' from web URLs (skill: flutter-setup-declarative-routing)
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // Fuentes bundleadas en el artefacto web; evita fetch a fonts.gstatic.com en cold start.
  GoogleFonts.config.allowRuntimeFetching = false;

  final prefs = await SharedPreferences.getInstance();
  final disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;
  final savedLocaleCode = prefs.getString(localePrefsKey) ?? 'es';

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
    ],
    child: const NeuroScaleApp(),
  );

  if (Env.hasSentry) {
    await SentryFlutter.init((options) {
      options.dsn = Env.sentryDsn;
      options.tracesSampleRate = 0.2;
      options.environment = Env.flavor;
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
    return MaterialApp.router(
      title: 'NeuroScale',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
