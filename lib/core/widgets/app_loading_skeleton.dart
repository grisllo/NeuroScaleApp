import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// A shimmer-like skeleton placeholder for list items (>300ms loads).
/// Shows [itemCount] rows of icon + two lines of text, matching the
/// look of a typical ListTile-based card.
class AppLoadingSkeleton extends StatefulWidget {
  const AppLoadingSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  State<AppLoadingSkeleton> createState() => _AppLoadingSkeletonState();
}

class _AppLoadingSkeletonState extends State<AppLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return _buildStaticList(context);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => _buildStaticList(context),
    );
  }

  Widget _buildStaticList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        88,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _SkeletonItem(shimmer: _controller.value),
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem({required this.shimmer});

  final double shimmer;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.outlineVariant;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHigh;
    final color = Color.lerp(base, highlight, shimmer)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          _Bone(width: 44, height: 44, radius: AppRadii.xl, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(
                  width: double.infinity,
                  height: 14,
                  radius: AppRadii.sm,
                  color: color,
                ),
                const SizedBox(height: 6),
                _Bone(
                  width: 160,
                  height: 12,
                  radius: AppRadii.sm,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
