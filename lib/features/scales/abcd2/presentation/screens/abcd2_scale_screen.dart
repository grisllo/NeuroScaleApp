import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../abcd2/domain/abcd2_calculator.dart';
import '../../../abcd2/domain/abcd2_definition.dart';
import '../../../shared/domain/entities/scale_item.dart';
import '../providers/abcd2_provider.dart';

class Abcd2ScaleScreen extends ConsumerWidget {
  const Abcd2ScaleScreen({super.key});

  static const _definition = Abcd2Definition();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(abcd2AnswersProvider);
    final allAnswered =
        _definition.items.every((item) => answers.containsKey(item.key));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABCD2'),
        actions: [
          TextButton(
            onPressed: () => ref.read(abcd2AnswersProvider.notifier).reset(),
            child: const Text('Restablecer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Estratificación del riesgo de ictus tras AIT\n'
                '(ataque isquémico transitorio)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._definition.items.map(
            (item) => _Abcd2ItemCard(
              item: item,
              selectedValue: answers[item.key],
              onChanged: (value) =>
                  ref.read(abcd2AnswersProvider.notifier).setAnswer(item.key, value),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed:
                allAnswered ? () => _calculate(context, ref, answers) : null,
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
    final result = calculateAbcd2(answers);
    ref.read(abcd2AnswersProvider.notifier).reset();
    context.go('/result', extra: (result, _definition.displayName, 'abcd2'));
  }
}

class _Abcd2ItemCard extends StatelessWidget {
  const _Abcd2ItemCard({
    required this.item,
    required this.selectedValue,
    required this.onChanged,
  });

  final ScaleItem item;
  final int? selectedValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (selectedValue != null)
                  Chip(
                    label: Text('+$selectedValue'),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...item.options.map(
              ((int, String) opt) => RadioListTile<int>(
                value: opt.$1,
                groupValue: selectedValue,
                onChanged: (v) => onChanged(v!),
                title: Text(opt.$2),
                secondary: opt.$1 > 0
                    ? Chip(
                        label: Text('+${opt.$1}'),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    : null,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
