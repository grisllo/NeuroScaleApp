import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../features/evaluations/domain/entities/evaluation.dart';
import '../../../../features/scales/shared/domain/entities/severity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/history_controller.dart';
import 'evaluation_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final historyAsync = ref.watch(historyControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('home'),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(historyControllerProvider),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
        data: (evaluations) => evaluations.isEmpty
            ? _EmptyState(l10n: l10n)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: evaluations.length,
                itemBuilder: (_, i) => _EvaluationCard(
                  evaluation: evaluations[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EvaluationDetailScreen(
                        evaluation: evaluations[i],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.historyEmpty,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.goNamed('home'),
            child: Text(l10n.historyEmptyAction),
          ),
        ],
      ),
    );
  }
}

class _EvaluationCard extends StatelessWidget {
  const _EvaluationCard({
    required this.evaluation,
    required this.onTap,
  });

  final Evaluation evaluation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = _severityFromInterpretation(evaluation.interpretation);
    final severityColor = _severityColor(context, severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Chip(
              label: Text(
                evaluation.scaleType.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: theme.colorScheme.primary,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                evaluation.caseDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                _relativeDate(evaluation.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: severityColor, width: 1),
                ),
                child: Text(
                  evaluation.interpretation,
                  style: TextStyle(
                    fontSize: 11,
                    color: severityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Severity _severityFromInterpretation(String interpretation) {
    final lower = interpretation.toLowerCase();
    if (lower.contains('grave') || lower.contains('total') || lower.contains('fallecido') || lower.contains('alto')) {
      return Severity.severe;
    }
    if (lower.contains('moderado') || lower.contains('moderada')) {
      return Severity.moderate;
    }
    if (lower.contains('leve') || lower.contains('bajo')) return Severity.mild;
    return Severity.none;
  }

  Color _severityColor(BuildContext context, Severity severity) =>
      switch (severity) {
        Severity.mild => Colors.green.shade600,
        Severity.moderate => Colors.orange.shade700,
        Severity.severe => Colors.red.shade700,
        Severity.none => Theme.of(context).colorScheme.secondary,
      };
}
