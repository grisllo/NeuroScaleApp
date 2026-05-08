import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/extensions/scale_key_resolver.dart';
import '../../../barthel/domain/barthel_calculator.dart';
import '../../../barthel/domain/barthel_definition.dart';
import '../../../shared/domain/entities/scale_item.dart';
import '../providers/barthel_provider.dart';

class BarthelScaleScreen extends ConsumerWidget {
  const BarthelScaleScreen({super.key});

  static const _definition = BarthelDefinition();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(barthelAnswersProvider);
    final allAnswered = _definition.items.every(
      (item) => answers.containsKey(item.key),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.barthelTitle),
        actions: [
          TextButton(
            onPressed: () => ref.read(barthelAnswersProvider.notifier).reset(),
            child: Text(context.l10n.resetButton),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._definition.items.map(
            (item) => _BarthelItemCard(
              item: item,
              selectedValue: answers[item.key],
              onChanged: (value) => ref
                  .read(barthelAnswersProvider.notifier)
                  .setAnswer(item.key, value),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: allAnswered
                ? () => _calculate(context, ref, answers)
                : null,
            child: Text(context.l10n.calculateButton),
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
    final result = calculateBarthel(answers);
    ref.read(barthelAnswersProvider.notifier).reset();
    context.push(
      '/result',
      extra: (result, _definition.displayName, 'barthel'),
    );
  }
}

class _BarthelItemCard extends StatelessWidget {
  const _BarthelItemCard({
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
                Text(
                  context.l10n.resolveKey(item.labelKey),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (selectedValue != null)
                  Chip(
                    label: Text('$selectedValue'),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
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
                // ignore: deprecated_member_use
                groupValue: selectedValue,
                // ignore: deprecated_member_use
                onChanged: (v) => onChanged(v!),
                title: Text('${opt.$1} — ${context.l10n.resolveKey(opt.$2)}'),
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
