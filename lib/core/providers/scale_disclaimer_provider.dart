import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefsKey = 'disclaimer_seen_scales';

class ScaleDisclaimerNotifier extends Notifier<Set<String>> {
  ScaleDisclaimerNotifier([this._prefs, Set<String>? initial])
    : _initial = initial ?? const {};

  final SharedPreferences? _prefs;
  final Set<String> _initial;

  @override
  Set<String> build() => _initial;

  void markSeen(String scaleType) {
    final updated = {...state, scaleType};
    state = updated;
    _prefs?.setString(_kPrefsKey, updated.join(','));
  }

  bool hasSeen(String scaleType) => state.contains(scaleType);
}

final scaleDisclaimerProvider =
    NotifierProvider<ScaleDisclaimerNotifier, Set<String>>(
      // Overridden in main.dart with real SharedPreferences + initial state.
      () => throw UnimplementedError(),
    );
