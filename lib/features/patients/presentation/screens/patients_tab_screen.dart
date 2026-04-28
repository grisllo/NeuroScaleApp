import 'package:flutter/material.dart';

/// Placeholder screen for the Pacientes tab.
/// Full implementation delivered in subfase 3.2.
class PatientsTabScreen extends StatelessWidget {
  const PatientsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              Text(
                'Aún no tienes pacientes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí verás el historial de evolución de cada paciente '
                'anonimizado que registres.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Disponible próximamente — subfase 3.2'),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo paciente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
