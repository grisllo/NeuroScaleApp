import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Registro'),
      ),
      GoRoute(
        path: '/scales/gcs',
        name: 'gcs',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Glasgow Coma Scale'),
      ),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Resultado'),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Historial'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body:
          Center(child: Text(state.error?.toString() ?? 'Ruta no encontrada')),
    ),
  );
});

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NeuroScale')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('home');
            }
          },
        ),
      ),
      body: Center(
        child: Text(
          'Pantalla "$title" pendiente de implementación.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
