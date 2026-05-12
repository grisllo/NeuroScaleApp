import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Círculo con checkmark animado — se dibuja solo con animación de trazo.
/// Ideal para estados de éxito tras guardar o confirmar una acción.
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({super.key, this.size = 72, this.color});

  final double size;

  /// Color del trazo. Si es null usa colorScheme.primary.
  final Color? color;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _circleScale;
  late final Animation<double> _circleOpacity;
  late final Animation<double> _checkProgress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppMotion.deliberate);

    // Círculo: escala y aparece en la primera mitad
    _circleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );
    _circleOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    // Checkmark: se dibuja en la segunda mitad
    _checkProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return _StaticCheck(size: widget.size, color: widget.color);
    }
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _CheckPainter(
            circleScale: _circleScale.value,
            circleOpacity: _circleOpacity.value,
            checkProgress: _checkProgress.value,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _StaticCheck extends StatelessWidget {
  const _StaticCheck({required this.size, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CheckPainter(
          circleScale: 1,
          circleOpacity: 1,
          checkProgress: 1,
          color: c,
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({
    required this.circleScale,
    required this.circleOpacity,
    required this.checkProgress,
    required this.color,
  });

  final double circleScale;
  final double circleOpacity;
  final double checkProgress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final strokeW = size.width * 0.075;

    // ── Círculo de fondo (tonal surface) ──────────────────────────────
    if (circleOpacity > 0 && circleScale > 0) {
      final bgPaint = Paint()
        ..color = color.withValues(alpha: 0.15 * circleOpacity)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(circleScale);
      canvas.translate(-cx, -cy);
      canvas.drawCircle(Offset(cx, cy), r * 0.92, bgPaint);
      canvas.restore();
    }

    // ── Arco del círculo ───────────────────────────────────────────────
    if (circleScale > 0 && circleOpacity > 0) {
      final circlePaint = Paint()
        ..color = color.withValues(alpha: circleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(circleScale);
      canvas.translate(-cx, -cy);
      canvas.drawCircle(Offset(cx, cy), r * 0.82, circlePaint);
      canvas.restore();
    }

    // ── Checkmark ─────────────────────────────────────────────────────
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final p1 = Offset(size.width * 0.24, size.height * 0.50);
      final p2 = Offset(size.width * 0.44, size.height * 0.70);
      final p3 = Offset(size.width * 0.76, size.height * 0.32);

      final len1 = (p2 - p1).distance;
      final len2 = (p3 - p2).distance;
      final totalLen = len1 + len2;
      final drawn = checkProgress * totalLen;

      if (drawn <= len1) {
        final t = drawn / len1;
        canvas.drawLine(p1, Offset.lerp(p1, p2, t)!, checkPaint);
      } else {
        canvas.drawLine(p1, p2, checkPaint);
        final t = (drawn - len1) / len2;
        canvas.drawLine(p2, Offset.lerp(p2, p3, t)!, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.circleScale != circleScale ||
      old.circleOpacity != circleOpacity ||
      old.checkProgress != checkProgress ||
      old.color != color;
}
