import 'package:flutter/material.dart';

/// Centralised palette for NeuroScale.
///
/// Tone: calm clinical — desaturated teal primary, warm-neutral surfaces,
/// clinical semantics (success/warning/danger/info) with tonal surface pairs.
abstract final class AppColors {
  // Brand primary (desaturated medical teal).
  static const Color primary = Color(0xFF0F6F8A);
  static const Color primaryHover = Color(0xFF0C5C73);
  static const Color secondary = Color(0xFF445A66);

  // Surfaces — light.
  static const Color surfaceLight = Color(0xFFF7F9FB);
  static const Color surfaceLightContainer = Color(0xFFFFFFFF);
  static const Color surfaceLightContainerHigh = Color(0xFFEEF2F5);

  // Surfaces — dark.
  static const Color surfaceDark = Color(0xFF0E1419);
  static const Color surfaceDarkContainer = Color(0xFF161D24);
  static const Color surfaceDarkContainerHigh = Color(0xFF1F2730);

  // Text — light.
  static const Color textPrimaryLight = Color(0xFF0F1A22);
  static const Color textSecondaryLight = Color(0xFF4A5862);

  // Text — dark.
  static const Color textPrimaryDark = Color(0xFFE8EEF2);
  static const Color textSecondaryDark = Color(0xFFAFBCC4);

  // Outlines.
  static const Color outlineLight = Color(0xFFD8DEE3);
  static const Color outlineVariantLight = Color(0xFFE7ECF0);
  static const Color outlineDark = Color(0xFF2A333C);
  static const Color outlineVariantDark = Color(0xFF1F2730);

  // Clinical semantics — foreground + tonal surface pair.
  static const Color successFg = Color(0xFF0E7C66);
  static const Color successSurfaceLight = Color(0xFFE6F4F1);
  static const Color successSurfaceDark = Color(0xFF103A33);

  static const Color warningFg = Color(0xFFB5651D);
  static const Color warningSurfaceLight = Color(0xFFFBEFE3);
  static const Color warningSurfaceDark = Color(0xFF3D2A14);

  static const Color dangerFg = Color(0xFFB5354F);
  static const Color dangerSurfaceLight = Color(0xFFFBE9ED);
  static const Color dangerSurfaceDark = Color(0xFF3D1A24);

  static const Color infoFg = Color(0xFF2C6BAA);
  static const Color infoSurfaceLight = Color(0xFFE8F0F8);
  static const Color infoSurfaceDark = Color(0xFF132B45);
}
