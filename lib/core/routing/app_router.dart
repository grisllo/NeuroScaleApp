import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env/env.dart';
import '../../core/providers/disclaimer_provider.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../features/auth/presentation/screens/disclaimer_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/evaluations/presentation/screens/result_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/scales/barthel/presentation/screens/barthel_scale_screen.dart';
import '../../features/scales/gcs/presentation/screens/gcs_scale_screen.dart';
import '../../features/scales/rankin/presentation/screens/rankin_scale_screen.dart';
import '../../features/scales/shared/domain/entities/scale_result.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: Env.isDev,
    refreshListenable: notifier,
    redirect: (_, state) => notifier.redirect(state),
    routes: [
      GoRoute(
        path: '/disclaimer',
        name: 'disclaimer',
        builder: (_, __) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scales/gcs',
        name: 'gcs',
        builder: (_, __) => const GcsScaleScreen(),
      ),
      GoRoute(
        path: '/scales/rankin',
        name: 'rankin',
        builder: (_, __) => const RankinScaleScreen(),
      ),
      GoRoute(
        path: '/scales/barthel',
        name: 'barthel',
        builder: (_, __) => const BarthelScaleScreen(),
      ),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (_, state) {
          final extra = state.extra! as (ScaleResult, String, String);
          return ResultScreen(
            result: extra.$1,
            scaleTitle: extra.$2,
            scaleType: extra.$3,
          );
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (_, __) => const HistoryScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(state.error?.toString() ?? 'Ruta no encontrada'),
      ),
    ),
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
    _ref.listen(disclaimerAcceptedProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(GoRouterState state) {
    final disclaimerAccepted = _ref.read(disclaimerAcceptedProvider);
    final session = _ref.read(sessionProvider);
    final isLoggedIn = session.asData?.value != null;
    final location = state.matchedLocation;

    const authRoutes = {'/login', '/register'};
    const publicRoutes = {'/login', '/register', '/disclaimer'};

    if (!disclaimerAccepted && !publicRoutes.contains(location)) {
      return '/disclaimer';
    }
    if (!isLoggedIn && !publicRoutes.contains(location)) {
      return '/login';
    }
    if (isLoggedIn && authRoutes.contains(location)) {
      return '/';
    }
    return null;
  }
}

// ── Home screen ────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroScale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                session.email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          Text(
            'Escalas neurológicas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Glasgow Coma Scale'),
              subtitle: const Text('Evaluación del nivel de consciencia'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed('gcs'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Barthel Index'),
              subtitle: const Text('Índice de actividades de la vida diaria'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed('barthel'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('mRS (Modified Rankin Scale)'),
              subtitle: const Text('Escala de discapacidad neurológica post-ictus'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed('rankin'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Historial'),
              subtitle: const Text('Evaluaciones guardadas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed('history'),
            ),
          ),
        ],
      ),
    );
  }
}

