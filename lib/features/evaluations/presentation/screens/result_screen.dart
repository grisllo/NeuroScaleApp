import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/failure_l10n.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/scale_key_resolver.dart';
import '../../../../core/providers/scale_disclaimer_provider.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/clinical_colors.dart';
import '../../../../core/utils/pii_detector.dart';
import '../../../../core/widgets/animated_check.dart';
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

// Maps item data keys → ARB label keys for each scale type.
const _kItemLabelKeys = <String, Map<String, String>>{
  'gcs': {
    'eye': 'gcsEyeLabel',
    'verbal': 'gcsVerbalLabel',
    'motor': 'gcsMotorLabel',
  },
  'nihss': {
    'loc': 'nihss1aLocLabel',
    'loc_questions': 'nihss1bLocQuestionsLabel',
    'loc_commands': 'nihss1cLocCommandsLabel',
    'gaze': 'nihss2GazeLabel',
    'visual': 'nihss3VisualLabel',
    'facial': 'nihss4FacialLabel',
    'motor_arm_left': 'nihss5aMotorArmLLabel',
    'motor_arm_right': 'nihss5bMotorArmRLabel',
    'motor_leg_left': 'nihss6aMotorLegLLabel',
    'motor_leg_right': 'nihss6bMotorLegRLabel',
    'ataxia': 'nihss7AtaxiaLabel',
    'sensory': 'nihss8SensoryLabel',
    'language': 'nihss9LanguageLabel',
    'dysarthria': 'nihss10DysarthriaLabel',
    'neglect': 'nihss11NeglectLabel',
  },
  'abcd2': {
    'age': 'abcd2AgeLabel',
    'bp': 'abcd2BpLabel',
    'clinical': 'abcd2ClinicalLabel',
    'duration': 'abcd2DurationLabel',
    'diabetes': 'abcd2DiabetesLabel',
  },
  'barthel': {
    'feeding': 'barthelItemFeeding',
    'bathing': 'barthelItemBathing',
    'grooming': 'barthelItemGrooming',
    'dressing': 'barthelItemDressing',
    'bowels': 'barthelItemBowels',
    'bladder': 'barthelItemBladder',
    'toilet_use': 'barthelItemToiletUse',
    'transfer': 'barthelItemTransfer',
    'mobility': 'barthelItemMobility',
    'stairs': 'barthelItemStairs',
  },
};

class ResultScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(scaleDisclaimerProvider.notifier);
      if (!notifier.hasSeen(widget.scaleType)) {
        notifier.markSeen(widget.scaleType);
        final l10n = context.l10n;
        final scheme = Theme.of(context).colorScheme;
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: scheme.onInverseSurface,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.disclaimerBody)),
              ],
            ),
            duration: const Duration(seconds: 4),
            dismissDirection: kIsWeb
                ? DismissDirection.down
                : DismissDirection.horizontal,
            action: kIsWeb
                ? SnackBarAction(
                    label: l10n.closeButton,
                    onPressed: messenger.hideCurrentSnackBar,
                  )
                : null,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final clinical = Theme.of(context).clinicalColors;
    final clinicalPair = switch (widget.result.severity) {
      Severity.mild => clinical.success,
      Severity.moderate => clinical.warning,
      Severity.severe => clinical.danger,
      Severity.none => clinical.info,
    };

    final labelKeys = _kItemLabelKeys[widget.scaleType] ?? {};
    // Rankin has a single item identical to totalScore — breakdown is redundant.
    final showBreakdown = widget.result.itemScores.length > 1;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    return Scaffold(
      appBar: AppBar(title: Text(widget.scaleTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: Column(
            children: [
              // ── Severity hero — bullseye circle ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    _AnimatedEntrance(
                      child: Container(
                        width: 172,
                        height: 172,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: clinicalPair.surface,
                          border: Border.all(
                            color: clinicalPair.foreground,
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 136,
                            height: 72,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: RepaintBoundary(
                                child: AnimatedScore(
                                  score: widget.result.totalScore,
                                  maxScore: widget.result.maxScore,
                                  color: clinicalPair.foreground,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        color: clinicalPair.foreground,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ), // _AnimatedEntrance
                    const SizedBox(height: 16),
                    SeverityBadge(
                      severity: widget.result.severity,
                      label: l10n.resolveKey(
                        widget.result.severity.interpretationKey,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Breakdown ─────────────────────────────────────────────────────
              if (showBreakdown)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    children: [
                      Text(
                        l10n.resultBreakdown,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final (i, MapEntry(key: key, value: score))
                                in widget
                                    .result
                                    .itemScores
                                    .entries
                                    .indexed) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  color: scheme.outlineVariant,
                                ),
                              _BreakdownRow(
                                label: () {
                                  final labelKey = labelKeys[key];
                                  return labelKey != null
                                      ? l10n.resolveKey(labelKey)
                                      : key.toUpperCase();
                                }(),
                                value: score,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Spacer(),

              // ── Sticky bottom: Save ───────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(color: scheme.outlineVariant, width: 0.5),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openSaveDialog(context),
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.resultSaveButton),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSaveDialog(BuildContext context) async {
    final session = ref.read(sessionProvider).asData?.value;
    if (session == null) {
      if (context.mounted) context.go('/login');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _SaveEvaluationDialog(
        result: widget.result,
        scaleType: widget.scaleType,
        userId: session.id,
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUntestable = value == 9;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            isUntestable ? 'N/E' : '$value',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isUntestable ? scheme.onSurfaceVariant : null,
            ),
          ),
        ],
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

enum _SaveState { idle, busy, success }

class _SaveEvaluationDialogState extends ConsumerState<_SaveEvaluationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newAliasController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedValue;
  _SaveState _saveState = _SaveState.idle;
  String? _errorMessage;

  bool get _isCreatingNew => _selectedValue == _kNewPatientSentinel;
  bool get _busy => _saveState == _SaveState.busy;

  @override
  void dispose() {
    _newAliasController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saveState = _SaveState.busy;
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
        finalPatientId = _selectedValue;
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
      setState(() => _saveState = _SaveState.success);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveState = _SaveState.idle;
        _errorMessage = failureMessage(e, context.l10n);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final patientsAsync = ref.watch(patientsControllerProvider);

    // ── Estado de éxito: checkmark animado ────────────────────────────
    if (_saveState == _SaveState.success) {
      return AlertDialog(
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedCheck(
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.saveSuccessMessage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
                  failureMessage(e, context.l10n),
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
      validator: (_) =>
          _selectedValue == null ? l10n.patientPickerRequired : null,
      onChanged: (value) {
        setState(() => _selectedValue = value);
      },
    );
  }
}

// ── Animación de entrada para el círculo de severidad ─────────────────────────

class _AnimatedEntrance extends StatefulWidget {
  const _AnimatedEntrance({required this.child});

  final Widget child;

  @override
  State<_AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<_AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppMotion.deliberate);
    _scale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.emphasized));
    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(scale: _scale.value, child: child),
      ),
      child: widget.child,
    );
  }
}
