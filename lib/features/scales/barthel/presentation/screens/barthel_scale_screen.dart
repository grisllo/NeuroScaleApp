import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../barthel/domain/barthel_calculator.dart';
import '../../../barthel/domain/barthel_definition.dart';
import '../../../shared/presentation/widgets/scale_item_card.dart';
import '../providers/barthel_provider.dart';

class BarthelScaleScreen extends ConsumerWidget {
  const BarthelScaleScreen({super.key});

  static const _definition = BarthelDefinition();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(barthelAnswersProvider);
    final total = _definition.items.length;
    final answered = answers.length;
    final allAnswered = answered == total;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.barthelTitle),
        actions: [
          TextButton(
            onPressed: () => ref.read(barthelAnswersProvider.notifier).reset(),
            child: Text(context.l10n.resetButton),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: total > 0 ? answered / total : 0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (_, value, _) =>
                LinearProgressIndicator(value: value, minHeight: 4),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._definition.items.map(
            (item) => ScaleItemCard(
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
