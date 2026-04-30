import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/algorithms/algorithms_registry.dart';
import '../../domain/entities/algorithm_definition.dart';
import '../l10n/algorithm_l10n.dart';

class AlgorithmsTabScreen extends StatelessWidget {
  const AlgorithmsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.algorithmsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.algorithmsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ...kAlgorithms.map(
            (def) => _AlgorithmCard(definition: def),
          ),
        ],
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  const _AlgorithmCard({required this.definition});

  final AlgorithmDefinition definition;

  static IconData _iconFor(String id) => switch (id) {
        'strokeCode' => Icons.emergency_rounded,
        'htaIctus' => Icons.monitor_heart_outlined,
        'sah' => Icons.medical_services_rounded,
        _ => Icons.alt_route_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Icon(
              _iconFor(definition.id),
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          title: Text(
            l10n.algo(definition.titleKey),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(l10n.algo(definition.descriptionKey)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushNamed(
            'algorithm',
            pathParameters: {'id': definition.id},
          ),
        ),
      ),
    );
  }
}
