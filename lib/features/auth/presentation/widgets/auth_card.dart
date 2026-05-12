import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ns_logo.dart';

/// En tablet/desktop (≥600px): layout de marca adaptado al tema.
/// Claro: fondo teal + card blanca. Oscuro: fondo oscuro + card elevada + acento teal.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child, this.showLogo = true});

  final Widget child;
  final bool showLogo;

  static const double _maxWidth = 440;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surfaceDark : AppColors.primary;
    final cardColor = isDark ? AppColors.surfaceDarkContainer : Colors.white;
    final logoColor = isDark ? AppColors.primary : Colors.white;
    final nameColor = isDark ? AppColors.textPrimaryDark : Colors.white;
    final cardShape = isDark
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outlineDark, width: 1),
          )
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo) ...[
                  NsLogo(size: 72, color: logoColor),
                  const SizedBox(height: 12),
                  Text(
                    'NeuroScale',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: nameColor,
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
                    shape: cardShape,
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
