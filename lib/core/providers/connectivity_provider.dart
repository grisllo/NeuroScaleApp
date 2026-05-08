import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream del estado de red. Emite una lista de ConnectivityResult
/// cada vez que cambia la conectividad del dispositivo.
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  return Connectivity().onConnectivityChanged;
});

/// true cuando ninguna interfaz de red tiene conexión activa.
/// Devuelve false mientras el estado inicial está cargando (optimismo inicial).
final isOfflineProvider = Provider<bool>((ref) {
  return ref
          .watch(connectivityStreamProvider)
          .whenOrNull(
            data: (results) =>
                results.every((r) => r == ConnectivityResult.none),
          ) ??
      false;
});
