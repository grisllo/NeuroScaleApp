import 'package:flutter/widgets.dart';

import '../utils/breakpoints.dart';

/// Centra y limita el ancho del contenido en tablet y desktop.
/// En mobile pasa el child sin modificaciones.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.tablet) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width < Breakpoints.desktop ? 800 : 960,
        ),
        child: child,
      ),
    );
  }
}
