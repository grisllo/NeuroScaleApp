import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_tap_scale.dart';
import '../../../../features/auth/presentation/providers/session_provider.dart';

class ScalesTabScreen extends ConsumerWidget {
  const ScalesTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('NeuroScale')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          88,
        ),
        children: [
          if (session != null)
            Text(
              session.email,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.scalesTabTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ScaleCard(
            title: 'Glasgow Coma Scale',
            subtitle: context.l10n.gcsSubtitle,
            icon: Icons.psychology_rounded,
            onTap: () => context.pushNamed('gcs'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScaleCard(
            title: 'NIHSS',
            subtitle: context.l10n.nihssSubtitle,
            icon: Icons.health_and_safety_rounded,
            onTap: () => context.pushNamed('nihss'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScaleCard(
            title: 'ABCD2',
            subtitle: context.l10n.abcd2Subtitle,
            icon: Icons.warning_amber_rounded,
            onTap: () => context.pushNamed('abcd2'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScaleCard(
            title: 'Barthel Index',
            subtitle: context.l10n.barthelSubtitle,
            icon: Icons.checklist_rounded,
            onTap: () => context.pushNamed('barthel'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScaleCard(
            title: 'mRS (Modified Rankin Scale)',
            subtitle: context.l10n.rankinSubtitle,
            icon: Icons.accessibility_new_rounded,
            onTap: () => context.pushNamed('rankin'),
          ),
        ],
      ),
    );
  }
}

class _ScaleCard extends StatelessWidget {
  const _ScaleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedTapScale(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  icon,
                  color: scheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
