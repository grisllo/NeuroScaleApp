import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/clinical_colors.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/animated_tap_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/algorithms/algorithms_registry.dart';
import '../../domain/entities/algorithm_definition.dart';
import '../l10n/algorithm_l10n.dart';

class AlgorithmsTabScreen extends StatelessWidget {
  const AlgorithmsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= Breakpoints.tablet;
    final isDesktop = width >= Breakpoints.desktop;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.algorithmsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop
                ? 900
                : isTablet
                ? 800
                : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.algorithmsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...kAlgorithms.map((def) => _AlgorithmCard(definition: def)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  const _AlgorithmCard({required this.definition});

  final AlgorithmDefinition definition;

  static IconData _iconFor(String id) => switch (id) {
    'strokeCode' => Icons.emergency_rounded,
    'htaIctus' => Icons.monitor_heart_outlined,
    'sah' => Icons.medical_services_rounded,
    _ => Icons.alt_route_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clinical = Theme.of(context).clinicalColors;
    final scheme = Theme.of(context).colorScheme;

    final (iconBg, iconFg) = switch (definition.id) {
      'strokeCode' => (clinical.danger.surface, clinical.danger.foreground),
      'htaIctus' => (clinical.warning.surface, clinical.warning.foreground),
      'sah' => (clinical.info.surface, clinical.info.foreground),
      _ => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnimatedTapScale(
        onTap: () => context.pushNamed(
          'algorithm',
          pathParameters: {'id': definition.id},
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(_iconFor(definition.id), color: iconFg, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.algo(definition.titleKey),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.algo(definition.descriptionKey),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
