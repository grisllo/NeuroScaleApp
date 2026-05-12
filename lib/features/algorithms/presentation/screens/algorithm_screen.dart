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

class _AlgorithmScreenState extends ConsumerState<AlgorithmScreen>
    with SingleTickerProviderStateMixin {
  // exitDir: -1 = outgoing exits LEFT (forward), +1 = outgoing exits RIGHT (back)
  double _exitDir = -1;
  AlgorithmNode? _outgoingNode;
  bool _outgoingCanGoBack = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 320),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() => _outgoingNode = null);
          }
        });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(algorithmProvider.notifier).start(widget.definition);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate({required double exitDir, required VoidCallback action}) {
    final algoState = ref.read(algorithmProvider);
    if (algoState == null) return;
    setState(() {
      _exitDir = exitDir;
      _outgoingNode = algoState.currentNode;
      _outgoingCanGoBack = algoState.canGoBack;
    });
    action();
    _controller.forward(from: 0);
  }

  void _step(String optionId) => _navigate(
    exitDir: -1,
    action: () => ref.read(algorithmProvider.notifier).step(optionId),
  );

  void _back() => _navigate(
    exitDir: 1,
    action: () => ref.read(algorithmProvider.notifier).back(),
  );

  void _restart() {
    setState(() => _outgoingNode = null);
    _controller.reset();
    ref.read(algorithmProvider.notifier).restart();
  }

  Widget _buildNode(AlgorithmNode node, bool canGoBack, {bool active = true}) =>
      switch (node) {
        QuestionNode() => _QuestionBody(
          node: node,
          canGoBack: canGoBack,
          onStep: active ? _step : (_) {},
          onBack: active ? _back : () {},
        ),
        ResultNode() => _ResultBody(
          node: node,
          onRestart: active ? _restart : () {},
        ),
      };

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
            onPressed: _restart,
            child: Text(l10n.algorithmRestartButton),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width >= 600
                ? 900
                : double.infinity,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final isAnimating = _outgoingNode != null;

              if (!isAnimating) {
                return _buildNode(current, algoState.canGoBack);
              }

              final t = Curves.easeOut.transform(_controller.value);

              return ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Outgoing: exits in _exitDir direction
                    FractionalTranslation(
                      translation: Offset(_exitDir * t, 0),
                      child: _buildNode(
                        _outgoingNode!,
                        _outgoingCanGoBack,
                        active: false,
                      ),
                    ),
                    // Incoming: enters from opposite side
                    FractionalTranslation(
                      translation: Offset(-_exitDir * (1 - t), 0),
                      child: _buildNode(current, algoState.canGoBack),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Question ──────────────────────────────────────────────────────────────────

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    required this.node,
    required this.canGoBack,
    required this.onStep,
    required this.onBack,
  });

  final QuestionNode node;
  final bool canGoBack;
  final void Function(String optionId) onStep;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => onStep(opt.id),
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
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onBack,
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

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.node, required this.onRestart});

  final ResultNode node;
  final VoidCallback onRestart;

  ClinicalColorPair _urgencyColors(
    AlgorithmUrgency urgency,
    ClinicalColors clinical,
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clinical = Theme.of(context).clinicalColors;
    final pair = _urgencyColors(node.urgency, clinical);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            l10n.algo(node.titleKey),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
              onPressed: onRestart,
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
