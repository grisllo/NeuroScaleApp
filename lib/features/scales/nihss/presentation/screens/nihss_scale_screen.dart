import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/extensions/scale_key_resolver.dart';
import '../../../nihss/domain/nihss_calculator.dart';
import '../../../nihss/domain/nihss_definition.dart';
import '../../../shared/domain/entities/scale_item.dart';
import '../providers/nihss_provider.dart';

class NihssScaleScreen extends ConsumerWidget {
  const NihssScaleScreen({super.key});

  static const _definition = NihssDefinition();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(nihssAnswersProvider);
    final allAnswered = _definition.items.every(
      (item) => answers.containsKey(item.key),
    );
    final isComa = answers[nihssKey1aLoc] == 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NIHSS'),
        actions: [
          TextButton(
            onPressed: () => ref.read(nihssAnswersProvider.notifier).reset(),
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
                'National Institutes of Health Stroke Scale\n'
                'Total 0-42 · Versión estándar AHA/ASA',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (isComa) ...[
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Paciente comatoso (1a = 3): puntúa los ítems '
                        'siguientes según la respuesta observada al '
                        'estímulo nociceptivo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ..._definition.items.map(
            (item) => _NihssItemCard(
              item: item,
              selectedValue: answers[item.key],
              onChanged: (value) => ref
                  .read(nihssAnswersProvider.notifier)
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
    final result = calculateNihss(answers);
    ref.read(nihssAnswersProvider.notifier).reset();
    context.push('/result', extra: (result, _definition.displayName, 'nihss'));
  }
}

class _NihssItemCard extends StatelessWidget {
  const _NihssItemCard({
    required this.item,
    required this.selectedValue,
    required this.onChanged,
  });

  final ScaleItem item;
  final int? selectedValue;
  final ValueChanged<int> onChanged;

  bool get _isUntestableSelected =>
      selectedValue != null && selectedValue == item.untestableValue;

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
                    context.l10n.resolveKey(item.labelKey),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (selectedValue != null)
                  Chip(
                    label: Text(
                      _isUntestableSelected ? 'UN' : '+$selectedValue',
                    ),
                    backgroundColor: _isUntestableSelected
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: _isUntestableSelected
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...item.options.map(
              ((int, String) opt) => _buildOption(context, opt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, (int, String) opt) {
    final isUntestable = opt.$1 == item.untestableValue;

    return RadioListTile<int>(
      value: opt.$1,
      groupValue: selectedValue,
      onChanged: (v) => onChanged(v!),
      title: Text(
        context.l10n.resolveKey(opt.$2),
        style: isUntestable
            ? TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              )
            : null,
      ),
      secondary: isUntestable
          ? null
          : opt.$1 > 0
          ? Chip(
              label: Text('+${opt.$1}'),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
