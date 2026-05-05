import 'package:flutter/animation.dart';

/// Motion tokens. Durations stay in 100–320ms range for micro-interactions;
/// `deliberate` is reserved for the score counter on result screens.
abstract final class AppMotion {
  // Durations.
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration deliberate = Duration(milliseconds: 600);

  // Curves.
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve standard = Curves.easeInOut;
}
