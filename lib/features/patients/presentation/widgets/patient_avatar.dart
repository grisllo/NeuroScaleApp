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

/// Avatar circular con las dos primeras letras del alias y un color
/// determinista basado en el ID del paciente.
class PatientAvatar extends StatelessWidget {
  const PatientAvatar({super.key, required this.patient, this.radius = 22});

  final Patient patient;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final trimmed = patient.alias.trim();
    final initials = trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.toUpperCase();
    final color =
        _kAvatarPalette[_stableHash(patient.id) % _kAvatarPalette.length];

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initials,
        style: TextStyle(
          color: Color.lerp(color, Colors.white, 0.65),
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}
