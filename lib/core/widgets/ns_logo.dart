import 'package:flutter/material.dart';

/// Logo vectorial de NeuroScale — cerebro dorsal + línea ECG.
/// Dibujado con CustomPainter: escalable a cualquier tamaño sin pérdida.
/// [color] por defecto usa el primary del tema; para fondos oscuros pasa Colors.white.
class NsLogo extends StatelessWidget {
  const NsLogo({super.key, this.size = 64, this.color});

  final double size;

  /// Color del trazo. Si es null usa colorScheme.primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrainLogoPainter(color: c)),
    );
  }
}

class _BrainLogoPainter extends CustomPainter {
  const _BrainLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // ── Cerebro — vista dorsal simplificada ───────────────────────────
    stroke.strokeWidth = w * 0.058;
    final brain = Path()
      ..moveTo(w * .50, h * .16)
      // lado izquierdo
      ..cubicTo(w * .38, h * .14, w * .22, h * .20, w * .15, h * .32)
      ..cubicTo(w * .07, h * .43, w * .08, h * .57, w * .16, h * .67)
      ..cubicTo(w * .23, h * .77, w * .35, h * .82, w * .50, h * .82)
      // lado derecho (simétrico)
      ..cubicTo(w * .65, h * .82, w * .77, h * .77, w * .84, h * .67)
      ..cubicTo(w * .92, h * .57, w * .93, h * .43, w * .85, h * .32)
      ..cubicTo(w * .78, h * .20, w * .62, h * .14, w * .50, h * .16)
      ..close();
    canvas.drawPath(brain, stroke);

    // ── Cisura interhemisférica ───────────────────────────────────────
    canvas.drawLine(
      Offset(w * .50, h * .16),
      Offset(w * .50, h * .82),
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.024
        ..strokeCap = StrokeCap.round,
    );

    // ── Línea ECG / heartbeat ────────────────────────────────────────
    stroke.strokeWidth = w * 0.052;
    final ecg = Path()
      ..moveTo(w * .12, h * .49)
      ..lineTo(w * .26, h * .49)
      ..lineTo(w * .32, h * .35)
      ..lineTo(w * .39, h * .63)
      ..lineTo(w * .44, h * .45)
      ..lineTo(w * .50, h * .49)
      ..lineTo(w * .56, h * .49)
      ..lineTo(w * .61, h * .35)
      ..lineTo(w * .68, h * .63)
      ..lineTo(w * .73, h * .45)
      ..lineTo(w * .88, h * .49);
    canvas.drawPath(ecg, stroke);
  }

  @override
  bool shouldRepaint(_BrainLogoPainter old) => old.color != color;
}
