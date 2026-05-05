import 'package:flutter/material.dart';

import '../../features/scales/shared/domain/entities/severity.dart';
import '../theme/app_motion.dart';
import '../theme/app_radii.dart';
import '../theme/clinical_colors.dart';

/// Animated badge that maps [Severity] to a clinical tonal chip.
/// Replaces hard-coded Colors.red/green/orange in the result screen.
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity, required this.label});

  final Severity severity;
  final String label;

  @override
  Widget build(BuildContext context) {
    final clinical = Theme.of(context).clinicalColors;
    final pair = switch (severity) {
      Severity.mild => clinical.success,
      Severity.moderate => clinical.warning,
      Severity.severe => clinical.danger,
      Severity.none => clinical.info,
    };

    final animate = !MediaQuery.of(context).disableAnimations;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0.0 : 1.0, end: 1.0),
      duration: AppMotion.normal,
      curve: AppMotion.enter,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(scale: 0.9 + 0.1 * value, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: pair.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: pair.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Solid dot + colour for compact inline use (e.g. history list rows).
class SeverityDot extends StatelessWidget {
  const SeverityDot({super.key, required this.severity});

  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final clinical = Theme.of(context).clinicalColors;
    final color = switch (severity) {
      Severity.mild => clinical.success.foreground,
      Severity.moderate => clinical.warning.foreground,
      Severity.severe => clinical.danger.foreground,
      Severity.none => clinical.info.foreground,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
