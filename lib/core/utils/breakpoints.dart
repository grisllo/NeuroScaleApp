/// Anchos de pantalla (px lógicos) para adaptar layouts.
/// Uso: `MediaQuery.sizeOf(context).width >= Breakpoints.tablet`
abstract final class Breakpoints {
  /// ≥600px — tablet / web compacto: NavigationRail, grid 2 columnas.
  static const double tablet = 600;

  /// ≥1024px — desktop / web expansivo: NavigationRail extendido, max-width 960px.
  static const double desktop = 1024;
}
