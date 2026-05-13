import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/clinical_colors.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/animated_tap_scale.dart';
import '../../../../core/widgets/fade_slide_item.dart';

class ScalesTabScreen extends StatelessWidget {
  const ScalesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= Breakpoints.tablet;
    final isDesktop = width >= Breakpoints.desktop;
    final clinical = Theme.of(context).clinicalColors;
    final scheme = Theme.of(context).colorScheme;

    final rawCards = [
      _ScaleCard(
        title: 'Glasgow Coma Scale',
        subtitle: context.l10n.gcsSubtitle,
        icon: Icons.psychology_rounded,
        iconBackground: clinical.info.surface,
        iconColor: clinical.info.foreground,
        onTap: () => context.pushNamed('gcs'),
      ),
      _ScaleCard(
        title: 'NIHSS',
        subtitle: context.l10n.nihssSubtitle,
        icon: Icons.health_and_safety_rounded,
        iconBackground: clinical.danger.surface,
        iconColor: clinical.danger.foreground,
        onTap: () => context.pushNamed('nihss'),
      ),
      _ScaleCard(
        title: 'ABCD2',
        subtitle: context.l10n.abcd2Subtitle,
        icon: Icons.warning_amber_rounded,
        iconBackground: clinical.warning.surface,
        iconColor: clinical.warning.foreground,
        onTap: () => context.pushNamed('abcd2'),
      ),
      _ScaleCard(
        title: 'Barthel Index',
        subtitle: context.l10n.barthelSubtitle,
        icon: Icons.checklist_rounded,
        iconBackground: clinical.success.surface,
        iconColor: clinical.success.foreground,
        onTap: () => context.pushNamed('barthel'),
      ),
      _ScaleCard(
        title: 'mRS (Modified Rankin Scale)',
        subtitle: context.l10n.rankinSubtitle,
        icon: Icons.accessibility_new_rounded,
        iconBackground: scheme.secondaryContainer,
        iconColor: scheme.onSecondaryContainer,
        onTap: () => context.pushNamed('rankin'),
      ),
    ];

    final cards = [
      for (var i = 0; i < rawCards.length; i++)
        FadeSlideItem(
          delay: Duration(milliseconds: i * 60),
          child: rawCards[i],
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop
                ? 1100
                : isTablet
                ? 800
                : double.infinity,
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
                  crossAxisCount: isDesktop ? 3 : 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: isDesktop ? 2.5 : 3.0,
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
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(icon, color: iconColor, size: 24),
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
            ],
          ),
        ),
      ),
    );
  }
}
