import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../rankin/domain/rankin_calculator.dart';
import '../../../rankin/domain/rankin_definition.dart';
import '../providers/rankin_provider.dart';

class RankinScaleScreen extends ConsumerWidget {
  const RankinScaleScreen({super.key});

  static const _definition = RankinDefinition();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(rankinAnswersProvider);
    final selected = answers[rankinKeyScore];

    return Scaffold(
      appBar: AppBar(
        title: const Text('mRS (Modified Rankin Scale)'),
        actions: [
          TextButton(
            onPressed: () => ref.read(rankinAnswersProvider.notifier).reset(),
            child: const Text('Restablecer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Selecciona el grado que mejor describe la situación del paciente:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ..._definition.items.first.options.map(
            ((int, String) opt) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: selected == opt.$1
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: RadioListTile<int>(
                value: opt.$1,
                groupValue: selected,
                onChanged: (v) => ref
                    .read(rankinAnswersProvider.notifier)
                    .setAnswer(rankinKeyScore, v!),
                title: Text(
                  '${opt.$1} — ${opt.$2}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: selected != null
                ? () => _calculate(context, ref, answers)
                : null,
            child: const Text('Calcular puntuación'),
          ),
        ),
      ),
    );
  }

  void _calculate(
    BuildContext context,
    WidgetRef ref,
    Map<String, int> answers,
  ) {
    final result = calculateRankin(answers);
    ref.read(rankinAnswersProvider.notifier).reset();
    context.push('/result', extra: (result, _definition.displayName, 'rankin'));
  }
}
