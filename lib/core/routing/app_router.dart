import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env/env.dart';
import '../../core/providers/disclaimer_provider.dart';
import '../../core/routing/app_shell.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../features/auth/presentation/screens/disclaimer_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/evaluations/presentation/screens/result_screen.dart';
import '../../features/home/presentation/screens/scales_tab_screen.dart';
import '../../features/patients/presentation/screens/patient_detail_screen.dart';
import '../../features/patients/presentation/screens/patients_tab_screen.dart';
import '../../features/scales/abcd2/presentation/screens/abcd2_scale_screen.dart';
import '../../features/scales/barthel/presentation/screens/barthel_scale_screen.dart';
import '../../features/scales/gcs/presentation/screens/gcs_scale_screen.dart';
import '../../features/scales/nihss/presentation/screens/nihss_scale_screen.dart';
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
      // ── Auth routes (no shell) ─────────────────────────────────────────
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

      // ── Scale screens (fullscreen, no shell, pushed from ScalesTab) ────
      GoRoute(
        path: '/scales/gcs',
        name: 'gcs',
        builder: (_, __) => const GcsScaleScreen(),
      ),
      GoRoute(
        path: '/scales/nihss',
        name: 'nihss',
        builder: (_, __) => const NihssScaleScreen(),
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
        path: '/scales/abcd2',
        name: 'abcd2',
        builder: (_, __) => const Abcd2ScaleScreen(),
      ),

      // ── Result (fullscreen, no shell) ─────────────────────────────────
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

      // ── Shell with bottom navigation ──────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Inicio (escalas)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (_, __) => const ScalesTabScreen(),
              ),
            ],
          ),
          // Branch 1 — Pacientes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patients',
                name: 'patients',
                builder: (_, __) => const PatientsTabScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'patient-detail',
                    builder: (_, state) => PatientDetailScreen(
                      patientId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
