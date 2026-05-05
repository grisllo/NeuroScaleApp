import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Counts up from 0 to [score] over [AppMotion.deliberate] (600 ms).
/// Falls back to a static label when animations are disabled.
class AnimatedScore extends StatelessWidget {
  const AnimatedScore({
    super.key,
    required this.score,
    required this.maxScore,
    this.style,
    this.color,
  });

  final int score;
  final int maxScore;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? Theme.of(context).textTheme.displayLarge)
        ?.copyWith(color: color);

    if (MediaQuery.of(context).disableAnimations) {
      return Text('$score/$maxScore', style: effectiveStyle);
    }

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: score),
      duration: AppMotion.deliberate,
      curve: AppMotion.enter,
      builder: (_, value, _) =>
          Text('$value/$maxScore', style: effectiveStyle),
    );
  }
}
