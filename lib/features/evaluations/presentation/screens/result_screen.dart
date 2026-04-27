import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../features/scales/shared/domain/entities/scale_result.dart';
import '../../../../features/scales/shared/domain/entities/severity.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/evaluation.dart';
import '../providers/save_evaluation_controller.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.scaleTitle,
    required this.scaleType,
  });

  final ScaleResult result;
  final String scaleTitle;
  final String scaleType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final severityColor = _severityColor(context, result.severity);

    return Scaffold(
      appBar: AppBar(title: Text(scaleTitle)),
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
                        '${result.totalScore}/${result.maxScore}',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: severityColor,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          result.severity.label,
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
                const SizedBox(height: 32),
                Text(
                  'Desglose',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...result.itemScores.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key.toUpperCase()),
                        Text(
                          '${e.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _showSaveDialog(context, ref),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.resultSaveButton),
                ),
              ],
            ),
          ),
          // Disclaimer — always visible, cannot be dismissed
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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

  Future<void> _showSaveDialog(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null) {
      if (context.mounted) context.go('/login');
      return;
    }
    final l10n = context.l10n;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveDialogTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.caseDescriptionLabel,
                  hintText: l10n.caseDescriptionHint,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.fieldRequiredError
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.caseDescriptionWarning,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(ctx).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancelButton),
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final saveState = ref.watch(saveEvaluationControllerProvider);
              return FilledButton(
                onPressed: saveState.isLoading
                    ? null
                    : () => _save(
                          ctx,
                          ref,
                          session.id,
                          controller.text,
                          formKey,
                          l10n,
                        ),
                child: saveState.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.saveButton),
              );
            },
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _save(
    BuildContext ctx,
    WidgetRef ref,
    String userId,
    String description,
    GlobalKey<FormState> formKey,
    AppLocalizations l10n,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final evaluation = Evaluation(
      id: '',
      userId: userId,
      scaleType: scaleType,
      scaleVersion: 1,
      caseDescription: description.trim(),
      totalScore: result.totalScore,
      interpretation: result.interpretation,
      detailedScores: Map<String, dynamic>.from(result.itemScores),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(saveEvaluationControllerProvider.notifier).save(evaluation);

    if (!ctx.mounted) return;
    Navigator.of(ctx).pop();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(l10n.saveSuccessMessage)),
    );
  }

  Color _severityColor(BuildContext context, Severity severity) =>
      switch (severity) {
        Severity.mild => Colors.green.shade600,
        Severity.moderate => Colors.orange.shade700,
        Severity.severe => Colors.red.shade700,
        Severity.none => Theme.of(context).colorScheme.secondary,
      };
}
