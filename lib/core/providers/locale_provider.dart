import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SharedPreferences key used to persist the selected locale.
const localePrefsKey = 'app_locale';

/// Active app locale. Initialized via [ProviderScope] override in main().
/// The profile screen updates this provider and persists the choice.
final localeProvider = StateProvider<Locale>((ref) => const Locale('es'));
