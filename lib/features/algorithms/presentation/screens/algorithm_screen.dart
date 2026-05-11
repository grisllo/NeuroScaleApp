import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/clinical_colors.dart';
import '../../../../core/widgets/animated_tap_scale.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/algorithm_definition.dart';
import '../../domain/entities/algorithm_node.dart';
import '../../domain/entities/algorithm_urgency.dart';
import '../l10n/algorithm_l10n.dart';
import '../providers/algorithm_provider.dart';

class AlgorithmScreen extends ConsumerStatefulWidget {
  const AlgorithmScreen({super.key, required this.definition});

  final AlgorithmDefinition definition;

  @override
  ConsumerState<AlgorithmScreen> createState() => _AlgorithmScreenState();
}

class _AlgorithmScreenState extends ConsumerState<AlgorithmScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(algorithmProvider.notifier).start(widget.definition);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final algoState = ref.watch(algorithmProvider);

    if (algoState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = algoState.currentNode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.algo(widget.definition.titleKey)),
        actions: [
          TextButton(
            onPressed: () => ref.read(algorithmProvider.notifier).restart(),
            child: Text(l10n.algorithmRestartButton),
          ),
        ],
      ),
      body: switch (current) {
        QuestionNode() => _QuestionBody(
          node: current,
          canGoBack: algoState.canGoBack,
        ),
        ResultNode() => _ResultBody(node: current),
      },
    );
  }
}

// ── Question ──────────────────────────────────────────────────────────────────

class _QuestionBody extends ConsumerWidget {
  const _QuestionBody({required this.node, required this.canGoBack});

  final QuestionNode node;
  final bool canGoBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hint = node.hintKey != null ? l10n.algo(node.hintKey!) : null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: scheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.algo(node.questionKey),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          hint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...node.options.map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnimatedTapScale(
                    onTap: () =>
                        ref.read(algorithmProvider.notifier).step(opt.id),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.algo(opt.labelKey),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (canGoBack)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => ref.read(algorithmProvider.notifier).back(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(l10n.algorithmBackButton),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Result ────────────────────────────────────────────────────────────────────

class _ResultBody extends ConsumerWidget {
  const _ResultBody({required this.node});

  final ResultNode node;

  ClinicalColorPair _urgencyColors(
    AlgorithmUrgency urgency,
    ClinicalColors clinical,
    ColorScheme scheme,
  ) => switch (urgency) {
    AlgorithmUrgency.info => clinical.info,
    AlgorithmUrgency.low => clinical.success,
    AlgorithmUrgency.moderate => clinical.warning,
    AlgorithmUrgency.high => clinical.danger,
    AlgorithmUrgency.critical => clinical.danger,
  };

  static IconData _icon(AlgorithmUrgency urgency) => switch (urgency) {
    AlgorithmUrgency.info => Icons.info_outline_rounded,
    AlgorithmUrgency.low => Icons.check_circle_outline_rounded,
    AlgorithmUrgency.moderate => Icons.warning_amber_rounded,
    AlgorithmUrgency.high => Icons.priority_high_rounded,
    AlgorithmUrgency.critical => Icons.emergency_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final clinical = Theme.of(context).clinicalColors;
    final pair = _urgencyColors(node.urgency, clinical, scheme);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Urgency banner — uses ClinicalColors, adapts to dark mode
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: pair.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pair.foreground.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(_icon(node.urgency), color: pair.foreground, size: 22),
                const SizedBox(width: 10),
                Text(
                  l10n.urgencyLabel(node.urgency),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: pair.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Result title
          Text(
            l10n.algo(node.titleKey),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Recommendations
          Text(
            l10n.algorithmResultTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...node.recommendationKeys.indexed.map(
            ((int, String) entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: pair.surface,
                        child: Text(
                          '${entry.$1 + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: pair.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            l10n.algo(entry.$2),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => ref.read(algorithmProvider.notifier).restart(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.algorithmRestartButton),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: Text(l10n.cancelButton),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
