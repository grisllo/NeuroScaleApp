import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pantalla de autenticación: fondo navy de la marca + logo + card centrada.
/// Funciona igual en tema claro y oscuro — el fondo siempre es el navy del icono.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child, this.showLogo = true});

  final Widget child;
  final bool showLogo;

  static const double _maxWidth = 440;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDarkContainer : Colors.white;
    final cardBorder = isDark
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outlineDark),
          )
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 110,
                      height: 110,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'NeuroScale App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: Card(
                    color: cardColor,
                    elevation: isDark ? 0 : 4,
                    shape: cardBorder,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
