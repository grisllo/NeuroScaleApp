import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the user has accepted the medical disclaimer.
/// Initialized in main.dart from SharedPreferences before the app starts.
final disclaimerAcceptedProvider = StateProvider<bool>((ref) => false);
