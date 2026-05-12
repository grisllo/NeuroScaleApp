import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/extensions/scale_key_resolver.dart';
import '../../../../../core/widgets/scale_item_help_button.dart';
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
    final total = _definition.items.length;
    final answered = answers.length;
    final allAnswered = answered == total;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.abcd2Title),
        actions: [
          TextButton(
            onPressed: () => ref.read(abcd2AnswersProvider.notifier).reset(),
            child: Text(context.l10n.resetButton),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: total > 0 ? answered / total : 0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
            builder: (_, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                context.l10n.abcd2Subtitle,
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
              onChanged: (value) => ref
                  .read(abcd2AnswersProvider.notifier)
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
    final result = calculateAbcd2(answers);
    ref.read(abcd2AnswersProvider.notifier).reset();
    context.push('/result', extra: (result, _definition.displayName, 'abcd2'));
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
    final scheme = Theme.of(context).colorScheme;
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
                    context.l10n.resolveKey(item.labelKey),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.helpKey != null)
                  ScaleItemHelpButton(
                    labelKey: item.labelKey,
                    helpKey: item.helpKey!,
                  ),
                if (selectedValue != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('+$selectedValue'),
                    backgroundColor: scheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: selectedValue,
              onChanged: (int? v) { if (v != null) onChanged(v); },
              child: Column(
                children: item.options
                    .map(
                      (opt) => RadioListTile<int>(
                        value: opt.$1,
                        title: Text(context.l10n.resolveKey(opt.$2)),
                        secondary: opt.$1 > 0
                            ? Chip(
                                label: Text('+${opt.$1}'),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              )
                            : null,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        selected: selectedValue == opt.$1,
                        selectedTileColor: scheme.primaryContainer.withValues(
                          alpha: 0.35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
