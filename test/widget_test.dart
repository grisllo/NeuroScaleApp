import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuroscale_app/main.dart';

void main() {
  testWidgets('App boots and renders home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NeuroScaleApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('NeuroScale'), findsWidgets);
    expect(find.text('Glasgow Coma Scale'), findsOneWidget);
  });
}
