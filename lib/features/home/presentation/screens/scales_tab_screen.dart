import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/breakpoints.dart';

class ScalesTabScreen extends StatelessWidget {
  const ScalesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

    final cards = [
      _ScaleCard(
        title: 'Glasgow Coma Scale',
        subtitle: context.l10n.gcsSubtitle,
        icon: Icons.psychology_rounded,
        onTap: () => context.pushNamed('gcs'),
      ),
      _ScaleCard(
        title: 'NIHSS',
        subtitle: context.l10n.nihssSubtitle,
        icon: Icons.health_and_safety_rounded,
        onTap: () => context.pushNamed('nihss'),
      ),
      _ScaleCard(
        title: 'ABCD2',
        subtitle: context.l10n.abcd2Subtitle,
        icon: Icons.warning_amber_rounded,
        onTap: () => context.pushNamed('abcd2'),
      ),
      _ScaleCard(
        title: 'Barthel Index',
        subtitle: context.l10n.barthelSubtitle,
        icon: Icons.checklist_rounded,
        onTap: () => context.pushNamed('barthel'),
      ),
      _ScaleCard(
        title: 'mRS (Modified Rankin Scale)',
        subtitle: context.l10n.rankinSubtitle,
        icon: Icons.accessibility_new_rounded,
        onTap: () => context.pushNamed('rankin'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('NeuroScale')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              88,
            ),
            children: [
              const SizedBox(height: AppSpacing.lg),
              if (isTablet)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 3.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: cards,
                )
              else
                ...cards.expand(
                  (card) => [card, const SizedBox(height: AppSpacing.sm)],
                ),
            ],
          ),
        ),
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
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
                child: Icon(icon, color: scheme.onPrimaryContainer, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
