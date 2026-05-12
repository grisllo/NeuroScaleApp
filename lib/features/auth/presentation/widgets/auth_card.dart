import 'package:flutter/material.dart';

/// En tablet/desktop (≥600px): fondo primary oscuro + logo + card blanca centrada.
/// En móvil: devuelve el child directamente (cada pantalla gestiona su propio Scaffold).
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child, this.showLogo = true});

  final Widget child;

  /// Muestra el logo + nombre de la app encima de la card.
  final bool showLogo;

  static const double _maxWidth = 440;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo) ...[
                  const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NeuroScale',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: Card(
                    color: scheme.surface,
                    elevation: 4,
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
