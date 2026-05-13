import 'package:flutter/material.dart';

import '../../domain/entities/patient.dart';

const _kAvatarPalette = [
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFF6A1B9A),
  Color(0xFFAD1457),
  Color(0xFF00695C),
  Color(0xFF4527A0),
  Color(0xFF0277BD),
  Color(0xFF558B2F),
  Color(0xFF5D4037),
  Color(0xFF00838F),
];

/// Stable cross-platform hash of [s] using its code units.
/// String.hashCode differs between Dart VM and JS compilation, so we
/// compute our own hash to guarantee the same color on mobile and web.
int _stableHash(String s) {
  var h = 0;
  for (final c in s.codeUnits) {
    h = (h * 31 + c) & 0x7FFFFFFF;
  }
  return h;
}

/// Extrae iniciales inteligentes del alias:
/// - Multi-palabra ("Juan García") → primeras letras de cada palabra → "JG"
/// - Mixto letra+número ("P001") → primera letra + último dígito → "P1"
/// - Solo dígitos ("042") → últimos 2 dígitos → "42"
/// - Solo letras ("Ana") → primeros 2 caracteres → "AN"
String _initials(String alias) {
  final s = alias.trim();
  if (s.isEmpty) return '?';

  final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  final letters = s.replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ]'), '');
  final digits = s.replaceAll(RegExp(r'[^0-9]'), '');

  if (letters.isNotEmpty && digits.isNotEmpty) {
    return '${letters[0]}${digits[digits.length - 1]}'.toUpperCase();
  }
  if (letters.isEmpty && digits.isNotEmpty) {
    final start = digits.length > 2 ? digits.length - 2 : 0;
    return digits.substring(start);
  }
  final end = letters.length > 2 ? 2 : letters.length;
  return letters.substring(0, end).toUpperCase();
}

/// Avatar circular con iniciales inteligentes del alias y color determinista
/// basado en el ID del paciente.
class PatientAvatar extends StatelessWidget {
  const PatientAvatar({super.key, required this.patient, this.radius = 22});

  final Patient patient;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color =
        _kAvatarPalette[_stableHash(patient.id) % _kAvatarPalette.length];

    return Semantics(
      label: patient.alias,
      excludeSemantics: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color,
        child: Text(
          _initials(patient.alias),
          style: TextStyle(
            color: Color.lerp(color, Colors.white, 0.65),
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.75,
          ),
        ),
      ),
    );
  }
}
