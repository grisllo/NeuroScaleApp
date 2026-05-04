import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const localePrefsKey = 'app_locale';

class LocaleNotifier extends Notifier<Locale> {
  LocaleNotifier([this._initial = const Locale('es')]);

  final Locale _initial;

  @override
  Locale build() => _initial;

  void set(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
