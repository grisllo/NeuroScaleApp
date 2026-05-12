// Generador del icono de lanzador de NeuroScale.
// Uso (una sola vez, no es parte del CI):
//   flutter test test/icon_generator_test.dart --run-skipped
// Después:
//   dart run flutter_launcher_icons

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/core/widgets/ns_logo.dart';

void main() {
  testWidgets(
    'generate_launcher_icon',
    (tester) async {
      // Viewport 1024×1024 — fuente para flutter_launcher_icons.
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: Container(
            width: 1024,
            height: 1024,
            color: const Color(0xFF0F6F8A),
            child: const Center(child: NsLogo(size: 700, color: Colors.white)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (data != null) {
        await Directory('assets').create(recursive: true);
        final file = File('assets/icon.png');
        await file.writeAsBytes(data.buffer.asUint8List());
        debugPrint('✓ Icono guardado en: ${file.path}');
      }
    },
    skip: true, // Ejecutar manualmente: --run-skipped
  );
}
