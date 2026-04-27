import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../features/evaluations/domain/entities/evaluation.dart';
import '../../../../features/scales/shared/domain/entities/severity.dart';
import '../providers/history_controller.dart';

class EvaluationDetailScreen extends ConsumerWidget {
  const EvaluationDetailScreen({super.key, required this.evaluation});

  final Evaluation evaluation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final severity = _severityFromInterpretation(evaluation.interpretation);
    final severityColor = _severityColor(context, severity);

    return Scaffold(
      appBar: AppBar(
        title: Text(evaluation.scaleType.toUpperCase()),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${evaluation.totalScore}',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          evaluation.interpretation,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: severityColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _InfoRow(
                  label: 'Descripción',
                  value: evaluation.caseDescription,
                ),
                _InfoRow(
                  label: 'Fecha',
                  value: _formatDate(evaluation.createdAt),
                ),
                const SizedBox(height: 16),
                Text(
                  'Desglose',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...evaluation.detailedScores.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key.toUpperCase()),
                        Text(
                          '${e.value}',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.deleteEvaluationButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.disclaimerBody,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.deleteEvaluationButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(historyControllerProvider.notifier).delete(evaluation.id);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deleteSuccessMessage)),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
