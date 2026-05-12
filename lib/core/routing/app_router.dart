import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env/env.dart';
import '../../core/providers/disclaimer_provider.dart';
import '../../core/routing/app_shell.dart';
import '../../core/theme/app_motion.dart';
import '../../features/algorithms/domain/algorithms/algorithms_registry.dart';
import '../../features/algorithms/presentation/screens/algorithm_screen.dart';
import '../../features/algorithms/presentation/screens/algorithms_tab_screen.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../features/auth/presentation/screens/disclaimer_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/evaluations/presentation/screens/result_screen.dart';
import '../../features/home/presentation/screens/scales_tab_screen.dart';
import '../../features/patients/presentation/screens/patient_detail_screen.dart';
import '../../features/patients/presentation/screens/patients_tab_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/scales/abcd2/presentation/screens/abcd2_scale_screen.dart';
import '../../features/scales/barthel/presentation/screens/barthel_scale_screen.dart';
import '../../features/scales/gcs/presentation/screens/gcs_scale_screen.dart';
import '../../features/scales/nihss/presentation/screens/nihss_scale_screen.dart';
import '../../features/scales/rankin/presentation/screens/rankin_scale_screen.dart';
import '../../features/scales/shared/domain/entities/scale_result.dart';

/// Fade + subtle slide-up transition for pushed routes.
Page<void> _pushPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.normal,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.of(context).disableAnimations) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.enter,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

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
        builder: (_, _) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (_, _) => const ResetPasswordScreen(),
      ),

      // ── Shell with bottom navigation ──────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Escalas (+ pantallas de escala y resultado)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (_, _) => const ScalesTabScreen(),
                routes: [
                  GoRoute(
                    path: 'scales/gcs',
                    name: 'gcs',
                    pageBuilder: (_, s) => _pushPage(s, const GcsScaleScreen()),
                  ),
                  GoRoute(
                    path: 'scales/nihss',
                    name: 'nihss',
                    pageBuilder: (_, s) =>
                        _pushPage(s, const NihssScaleScreen()),
                  ),
                  GoRoute(
                    path: 'scales/rankin',
                    name: 'rankin',
                    pageBuilder: (_, s) =>
                        _pushPage(s, const RankinScaleScreen()),
                  ),
                  GoRoute(
                    path: 'scales/barthel',
                    name: 'barthel',
                    pageBuilder: (_, s) =>
                        _pushPage(s, const BarthelScaleScreen()),
                  ),
                  GoRoute(
                    path: 'scales/abcd2',
                    name: 'abcd2',
                    pageBuilder: (_, s) =>
                        _pushPage(s, const Abcd2ScaleScreen()),
                  ),
                  GoRoute(
                    path: 'result',
                    name: 'result',
                    pageBuilder: (_, state) {
                      final extra = state.extra;
                      if (extra == null) {
                        return _pushPage(state, const SizedBox.shrink());
                      }
                      final (result, title, type) =
                          extra as (ScaleResult, String, String);
                      return _pushPage(
                        state,
                        ResultScreen(
                          result: result,
                          scaleTitle: title,
                          scaleType: type,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 1 — Pacientes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patients',
                name: 'patients',
                builder: (_, _) => const PatientsTabScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'patient-detail',
                    pageBuilder: (_, state) => _pushPage(
                      state,
                      PatientDetailScreen(
                        patientId: state.pathParameters['id']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2 — Algoritmos (+ pantalla de ejecución)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/algorithms',
                name: 'algorithms',
                builder: (_, _) => const AlgorithmsTabScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'algorithm',
                    pageBuilder: (_, state) {
                      final id = state.pathParameters['id']!;
                      final definition = kAlgorithms.firstWhere(
                        (a) => a.id == id,
                      );
                      return _pushPage(
                        state,
                        AlgorithmScreen(definition: definition),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 3 — Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (_, _) => const ProfileScreen(),
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
    _ref.listen(sessionProvider, (_, _) => notifyListeners());
    _ref.listen(disclaimerAcceptedProvider, (_, _) => notifyListeners());
    _ref.listen(passwordRecoveryProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(GoRouterState state) {
    final disclaimerAccepted = _ref.read(disclaimerAcceptedProvider);
    final session = _ref.read(sessionProvider);
    final isRecovery =
        _ref.read(passwordRecoveryProvider).asData?.value ?? false;
    final isLoggedIn = session.asData?.value != null;
    final location = state.matchedLocation;

    const authRoutes = {'/login', '/register'};
    const publicRoutes = {
      '/login',
      '/register',
      '/disclaimer',
      '/forgot-password',
      '/reset-password',
    };

    if (isRecovery && location != '/reset-password') {
      return '/reset-password';
    }
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
