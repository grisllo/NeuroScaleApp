import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../gcs/domain/gcs_calculator.dart';
import '../../../gcs/domain/gcs_definition.dart';
import '../../../shared/presentation/widgets/scale_item_card.dart';
import '../providers/gcs_provider.dart';

class GcsScaleScreen extends ConsumerWidget {
  const GcsScaleScreen({super.key});

  static const _definition = GcsDefinition();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(gcsAnswersProvider);
    final total = _definition.items.length;
    final answered = answers.length;
    final allAnswered = answered == total;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.gcsTitle),
        actions: [
          TextButton(
            onPressed: () => ref.read(gcsAnswersProvider.notifier).reset(),
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
          ..._definition.items.map(
            (item) => ScaleItemCard(
              item: item,
              selectedValue: answers[item.key],
              onChanged: (value) => ref
                  .read(gcsAnswersProvider.notifier)
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
    final result = calculateGcs(answers);
    ref.read(gcsAnswersProvider.notifier).reset();
    context.push('/result', extra: (result, _definition.displayName, 'gcs'));
  }
}
