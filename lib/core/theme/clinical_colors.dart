import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Pair of foreground + tonal surface colours for a clinical semantic.
@immutable
class ClinicalColorPair {
  const ClinicalColorPair({required this.foreground, required this.surface});

  final Color foreground;
  final Color surface;

  ClinicalColorPair lerp(ClinicalColorPair? other, double t) {
    if (other == null) return this;
    return ClinicalColorPair(
      foreground: Color.lerp(foreground, other.foreground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

/// Theme extension exposing clinical semantic colours so screens never
/// hard-code `Colors.red.shade700` for severity.
@immutable
class ClinicalColors extends ThemeExtension<ClinicalColors> {
  const ClinicalColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final ClinicalColorPair success;
  final ClinicalColorPair warning;
  final ClinicalColorPair danger;
  final ClinicalColorPair info;

  static const ClinicalColors light = ClinicalColors(
    success: ClinicalColorPair(
      foreground: AppColors.successFg,
      surface: AppColors.successSurfaceLight,
    ),
    warning: ClinicalColorPair(
      foreground: AppColors.warningFg,
      surface: AppColors.warningSurfaceLight,
    ),
    danger: ClinicalColorPair(
      foreground: AppColors.dangerFg,
      surface: AppColors.dangerSurfaceLight,
    ),
    info: ClinicalColorPair(
      foreground: AppColors.infoFg,
      surface: AppColors.infoSurfaceLight,
    ),
  );

  static const ClinicalColors dark = ClinicalColors(
    success: ClinicalColorPair(
      foreground: AppColors.successFg,
      surface: AppColors.successSurfaceDark,
    ),
    warning: ClinicalColorPair(
      foreground: AppColors.warningFg,
      surface: AppColors.warningSurfaceDark,
    ),
    danger: ClinicalColorPair(
      foreground: AppColors.dangerFg,
      surface: AppColors.dangerSurfaceDark,
    ),
    info: ClinicalColorPair(
      foreground: AppColors.infoFg,
      surface: AppColors.infoSurfaceDark,
    ),
  );

  @override
  ClinicalColors copyWith({
    ClinicalColorPair? success,
    ClinicalColorPair? warning,
    ClinicalColorPair? danger,
    ClinicalColorPair? info,
  }) {
    return ClinicalColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  ClinicalColors lerp(ClinicalColors? other, double t) {
    if (other == null) return this;
    return ClinicalColors(
      success: success.lerp(other.success, t),
      warning: warning.lerp(other.warning, t),
      danger: danger.lerp(other.danger, t),
      info: info.lerp(other.info, t),
    );
  }
}

extension ClinicalColorsThemeX on ThemeData {
  ClinicalColors get clinicalColors =>
      extension<ClinicalColors>() ?? ClinicalColors.light;
}
