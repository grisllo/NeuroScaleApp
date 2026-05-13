abstract final class Env {
  static const String _rawSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _rawSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );
  static const String _rawRedirectUrl = String.fromEnvironment(
    'SUPABASE_REDIRECT_URL',
  );

  // Strips BOM (U+FEFF) and accidental /rest/v1 suffix from the base URL.
  static String get supabaseUrl {
    var url = _rawSupabaseUrl.replaceAll('﻿', '').trim();
    if (url.endsWith('/rest/v1/')) url = url.substring(0, url.length - 9);
    if (url.endsWith('/rest/v1')) url = url.substring(0, url.length - 8);
    return url;
  }

  static String get supabaseAnonKey =>
      _rawSupabaseAnonKey.replaceAll('﻿', '').trim();
  static String get redirectUrl => _rawRedirectUrl.replaceAll('﻿', '').trim();

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasSentry => sentryDsn.isNotEmpty;
  static bool get isDev => flavor == 'dev';
}
