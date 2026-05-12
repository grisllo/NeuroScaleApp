// Genera assets/icon.png para flutter_launcher_icons.
// Uso: dart run tool/generate_icon.dart
// Después: dart run flutter_launcher_icons

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _S = 1024;

void main() {
  print('Generando icono 1024×1024…');
  final image = img.Image(width: _S, height: _S);

  final bg = img.ColorRgb8(0x0F, 0x6F, 0x8A);
  final fg = img.ColorRgb8(0xFF, 0xFF, 0xFF);
  final fissure = img.ColorRgba8(0xFF, 0xFF, 0xFF, 110);

  img.fill(image, color: bg);

  final strokeR = (_S * 0.030).toInt(); // radio para trazo cerebro
  final ecgR = (_S * 0.027).toInt(); // radio para trazo ECG
  final fissR = (_S * 0.012).toInt(); // radio para cisura

  // ── Dibuja un trazo suave como serie de círculos rellenos ──────────
  void strokeCircles(List<(double, double)> pts, img.Color color, int r) {
    for (final (x, y) in pts) {
      img.fillCircle(
        image,
        x: (x * _S).round(),
        y: (y * _S).round(),
        radius: r,
        color: color,
      );
    }
  }

  // ── Muestrea una bezier cúbica en [steps] puntos ───────────────────
  List<(double, double)> bezier(
    double x0,
    double y0,
    double cx1,
    double cy1,
    double cx2,
    double cy2,
    double x1,
    double y1, {
    int steps = 120,
  }) {
    final pts = <(double, double)>[];
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final mt = 1.0 - t;
      final x =
          mt * mt * mt * x0 +
          3 * mt * mt * t * cx1 +
          3 * mt * t * t * cx2 +
          t * t * t * x1;
      final y =
          mt * mt * mt * y0 +
          3 * mt * mt * t * cy1 +
          3 * mt * t * t * cy2 +
          t * t * t * y1;
      pts.add((x, y));
    }
    return pts;
  }

  // ── Cerebro — contorno (vista dorsal) ─────────────────────────────
  for (final seg in [
    // lado izquierdo
    bezier(0.50, 0.16, 0.38, 0.14, 0.22, 0.20, 0.15, 0.32),
    bezier(0.15, 0.32, 0.07, 0.43, 0.08, 0.57, 0.16, 0.67),
    bezier(0.16, 0.67, 0.23, 0.77, 0.35, 0.82, 0.50, 0.82),
    // lado derecho
    bezier(0.50, 0.82, 0.65, 0.82, 0.77, 0.77, 0.84, 0.67),
    bezier(0.84, 0.67, 0.92, 0.57, 0.93, 0.43, 0.85, 0.32),
    bezier(0.85, 0.32, 0.78, 0.20, 0.62, 0.14, 0.50, 0.16),
  ]) {
    strokeCircles(seg, fg, strokeR);
  }

  // ── Cisura interhemisférica ────────────────────────────────────────
  final fissureSteps = 80;
  final fissurePts = List.generate(
    fissureSteps + 1,
    (i) => (0.50, 0.16 + i / fissureSteps * (0.82 - 0.16)),
  );
  strokeCircles(fissurePts, fissure, fissR);

  // ── Línea ECG / latido ─────────────────────────────────────────────
  // Genera puntos interpolados entre cada vértice de la polilínea
  final ecgVerts = [
    (0.12, 0.49),
    (0.26, 0.49),
    (0.32, 0.35),
    (0.39, 0.63),
    (0.44, 0.45),
    (0.50, 0.49),
    (0.56, 0.49),
    (0.61, 0.35),
    (0.68, 0.63),
    (0.73, 0.45),
    (0.88, 0.49),
  ];
  for (var i = 0; i < ecgVerts.length - 1; i++) {
    final (x0, y0) = ecgVerts[i];
    final (x1, y1) = ecgVerts[i + 1];
    final dist = math.sqrt(
      math.pow((x1 - x0) * _S, 2) + math.pow((y1 - y0) * _S, 2),
    );
    final steps = (dist / (ecgR * 0.6)).ceil().clamp(20, 200);
    final pts = List.generate(
      steps + 1,
      (j) => (x0 + (x1 - x0) * j / steps, y0 + (y1 - y0) * j / steps),
    );
    strokeCircles(pts, fg, ecgR);
  }

  // ── Guardar ────────────────────────────────────────────────────────
  final file = File('assets/icon.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
  print('✓  Icono guardado: ${file.path}');
  print('→  Siguiente paso: dart run flutter_launcher_icons');
}
