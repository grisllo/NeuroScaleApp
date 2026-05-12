// Genera assets/icon.png para flutter_launcher_icons.
// Uso: dart run tool/generate_icon.dart
// Después: dart run flutter_launcher_icons

import 'dart:io';

import 'package:image/image.dart' as img;

const _S = 1024;

void main() {
  print('Generando icono 1024×1024…');
  final image = img.Image(width: _S, height: _S);

  final bg = img.ColorRgb8(0x0F, 0x6F, 0x8A); // teal primario
  final fg = img.ColorRgb8(0xFF, 0xFF, 0xFF); // blanco
  final fissureColor = img.ColorRgba8(0xFF, 0xFF, 0xFF, 115); // ~45 % opacidad

  img.fill(image, color: bg);

  final thick = (_S * 0.060).round(); // trazo cerebro
  final ecgThick = (_S * 0.054).round(); // trazo ECG
  final fissThick = (_S * 0.026).round(); // cisura

  // ── Bezier cúbico: dibuja segmentos como una polilínea de 80 pasos ──
  void bezier(
    double x0, double y0,
    double cx1, double cy1,
    double cx2, double cy2,
    double x1, double y1,
    img.Color color,
    int thickness,
  ) {
    var px = (x0 * _S).toInt();
    var py = (y0 * _S).toInt();
    for (var i = 1; i <= 80; i++) {
      final t = i / 80.0;
      final mt = 1.0 - t;
      final nx =
          (mt * mt * mt * x0 +
              3 * mt * mt * t * cx1 +
              3 * mt * t * t * cx2 +
              t * t * t * x1) *
          _S;
      final ny =
          (mt * mt * mt * y0 +
              3 * mt * mt * t * cy1 +
              3 * mt * t * t * cy2 +
              t * t * t * y1) *
          _S;
      img.drawLine(
        image,
        x1: px,
        y1: py,
        x2: nx.toInt(),
        y2: ny.toInt(),
        color: color,
        thickness: thickness,
        antialias: true,
      );
      px = nx.toInt();
      py = ny.toInt();
    }
  }

  // ── Contorno del cerebro (vista dorsal simplificada) ─────────────────
  // Lado izquierdo
  bezier(0.50, 0.16, 0.38, 0.14, 0.22, 0.20, 0.15, 0.32, fg, thick);
  bezier(0.15, 0.32, 0.07, 0.43, 0.08, 0.57, 0.16, 0.67, fg, thick);
  bezier(0.16, 0.67, 0.23, 0.77, 0.35, 0.82, 0.50, 0.82, fg, thick);
  // Lado derecho (simétrico)
  bezier(0.50, 0.82, 0.65, 0.82, 0.77, 0.77, 0.84, 0.67, fg, thick);
  bezier(0.84, 0.67, 0.92, 0.57, 0.93, 0.43, 0.85, 0.32, fg, thick);
  bezier(0.85, 0.32, 0.78, 0.20, 0.62, 0.14, 0.50, 0.16, fg, thick);

  // ── Cisura interhemisférica ───────────────────────────────────────────
  img.drawLine(
    image,
    x1: (_S * 0.50).toInt(),
    y1: (_S * 0.16).toInt(),
    x2: (_S * 0.50).toInt(),
    y2: (_S * 0.82).toInt(),
    color: fissureColor,
    thickness: fissThick,
  );

  // ── Línea ECG / latido ────────────────────────────────────────────────
  final pts = [
    [0.12, 0.49],
    [0.26, 0.49],
    [0.32, 0.35],
    [0.39, 0.63],
    [0.44, 0.45],
    [0.50, 0.49],
    [0.56, 0.49],
    [0.61, 0.35],
    [0.68, 0.63],
    [0.73, 0.45],
    [0.88, 0.49],
  ];
  for (var i = 0; i < pts.length - 1; i++) {
    img.drawLine(
      image,
      x1: (pts[i][0] * _S).toInt(),
      y1: (pts[i][1] * _S).toInt(),
      x2: (pts[i + 1][0] * _S).toInt(),
      y2: (pts[i + 1][1] * _S).toInt(),
      color: fg,
      thickness: ecgThick,
      antialias: true,
    );
  }

  // ── Guardar ───────────────────────────────────────────────────────────
  final file = File('assets/icon.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
  print('✓  Icono guardado: ${file.path}');
  print('→  Siguiente paso: dart run flutter_launcher_icons');
}
