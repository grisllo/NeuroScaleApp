import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/scale_key_resolver.dart';
import '../../../../core/theme/clinical_colors.dart';
import '../../../../core/utils/pii_detector.dart';
import '../../../../core/widgets/animated_score.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../../features/auth/presentation/providers/session_provider.dart';
import '../../../../features/patients/domain/entities/patient.dart';
import '../../../../features/patients/presentation/providers/patients_controller.dart';
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
    final clinical = Theme.of(context).clinicalColors;
    final clinicalPair = switch (result.severity) {
      Severity.mild => clinical.success,
      Severity.moderate => clinical.warning,
      Severity.severe => clinical.danger,
      Severity.none => clinical.info,
    };

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
                      RepaintBoundary(
                        child: AnimatedScore(
                          score: result.totalScore,
                          maxScore: result.maxScore,
                          color: clinicalPair.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SeverityBadge(
                        severity: result.severity,
                        label: l10n.resolveKey(
                          result.severity.interpretationKey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.resultBreakdown,
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
                  onPressed: () => _openSaveDialog(context, ref),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.resultSaveButton),
                ),
              ],
            ),
          ),
          // Disclaimer — always visible, cannot be dismissed
          Semantics(
            label: l10n.disclaimerBody,
            container: true,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.disclaimerBody,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSaveDialog(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null) {
      if (context.mounted) context.go('/login');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _SaveEvaluationDialog(
        result: result,
        scaleType: scaleType,
        userId: session.id,
      ),
    );
  }
}

/// Sentinel value for the "+ Nuevo paciente" entry in the picker.
const String _kNewPatientSentinel = '__new_patient__';

class _SaveEvaluationDialog extends ConsumerStatefulWidget {
  const _SaveEvaluationDialog({
    required this.result,
    required this.scaleType,
    required this.userId,
  });

  final ScaleResult result;
  final String scaleType;
  final String userId;

  @override
  ConsumerState<_SaveEvaluationDialog> createState() =>
      _SaveEvaluationDialogState();
}

class _SaveEvaluationDialogState extends ConsumerState<_SaveEvaluationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newAliasController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedValue; // null = "Sin asignar"; patient.id; or sentinel
  bool _busy = false;
  String? _errorMessage;

  bool get _isCreatingNew => _selectedValue == _kNewPatientSentinel;

  @override
  void dispose() {
    _newAliasController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      String? finalPatientId;
      if (_isCreatingNew) {
        final created = await ref
            .read(patientsControllerProvider.notifier)
            .create(alias: _newAliasController.text.trim());
        finalPatientId = created.id;
      } else {
        finalPatientId = _selectedValue; // null or existing patient id
      }

      final evaluation = Evaluation(
        id: '',
        userId: widget.userId,
        scaleType: widget.scaleType,
        scaleVersion: 1,
        caseDescription: _notesController.text.trim(),
        totalScore: widget.result.totalScore,
        interpretation: widget.result.interpretation,
        detailedScores: Map<String, dynamic>.from(widget.result.itemScores),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        patientId: finalPatientId,
      );

      await ref
          .read(saveEvaluationControllerProvider.notifier)
          .save(evaluation);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.saveSuccessMessage)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final patientsAsync = ref.watch(patientsControllerProvider);

    return AlertDialog(
      title: Text(l10n.saveDialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              patientsAsync.when(
                loading: () => const SizedBox(
                  height: 56,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  e.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                data: (patients) => _buildPatientPicker(patients, l10n: l10n),
              ),
              if (_isCreatingNew) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newAliasController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.newPatientAliasLabel,
                    hintText: l10n.newPatientAliasHint,
                  ),
                  validator: (v) =>
                      _isCreatingNew && (v == null || v.trim().isEmpty)
                      ? l10n.patientAliasRequired
                      : null,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: l10n.evaluationNotesLabel,
                  hintText: l10n.caseDescriptionHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (value.length > 500) return l10n.caseDescriptionTooLong;
                  final matches = PiiDetector.detect(value);
                  if (matches.isNotEmpty) {
                    final kinds = matches
                        .map((m) => m.kind.name)
                        .toSet()
                        .join(', ');
                    return l10n.caseDescriptionPiiDetected(kinds);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.caseDescriptionWarning,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.saveButton),
        ),
      ],
    );
  }

  Widget _buildPatientPicker(
    List<Patient> patients, {
    required AppLocalizations l10n,
  }) {
    return DropdownButtonFormField<String?>(
      // ignore: deprecated_member_use
      value: _selectedValue,
      decoration: InputDecoration(labelText: l10n.patientPickerLabel),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.patientUnassigned),
        ),
        for (final p in patients)
          DropdownMenuItem<String?>(value: p.id, child: Text(p.alias)),
        DropdownMenuItem<String?>(
          value: _kNewPatientSentinel,
          child: Row(
            children: [
              const Icon(Icons.add, size: 18),
              const SizedBox(width: 8),
              Text(l10n.patientNewButton),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedValue = value);
      },
    );
  }
}
