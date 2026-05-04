import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/session_provider.dart';

class ScalesTabScreen extends ConsumerWidget {
  const ScalesTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('NeuroScale')),
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
          _ScaleCard(
            title: 'Glasgow Coma Scale',
            subtitle: 'Evaluación del nivel de consciencia',
            icon: Icons.psychology_rounded,
            onTap: () => context.pushNamed('gcs'),
          ),
          _ScaleCard(
            title: 'NIHSS',
            subtitle: 'National Institutes of Health Stroke Scale',
            icon: Icons.health_and_safety_rounded,
            onTap: () => context.pushNamed('nihss'),
          ),
          _ScaleCard(
            title: 'ABCD2',
            subtitle: 'Riesgo de ictus tras AIT',
            icon: Icons.warning_amber_rounded,
            onTap: () => context.pushNamed('abcd2'),
          ),
          _ScaleCard(
            title: 'Barthel Index',
            subtitle: 'Índice de actividades de la vida diaria',
            icon: Icons.checklist_rounded,
            onTap: () => context.pushNamed('barthel'),
          ),
          _ScaleCard(
            title: 'mRS (Modified Rankin Scale)',
            subtitle: 'Escala de discapacidad neurológica post-ictus',
            icon: Icons.accessibility_new_rounded,
            onTap: () => context.pushNamed('rankin'),
          ),
        ],
      ),
    );
  }
}

class _ScaleCard extends StatelessWidget {
  const _ScaleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
