import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/failure_l10n.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/scale_key_resolver.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/clinical_colors.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/severity_badge.dart';
import '../../../evaluations/domain/entities/evaluation.dart';
import '../../../evaluations/presentation/providers/evaluation_provider.dart';
import '../../../scales/shared/domain/scale_metadata.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_provider.dart';
import '../providers/patients_controller.dart';
import '../widgets/patient_avatar.dart';
import '../widgets/patient_edit_dialog.dart';
import '../widgets/patient_evolution_chart.dart';

/// Detail screen for a single patient.
/// Mobile: TabBar con Evaluaciones / Evolución.
/// Tablet/Desktop: lista de evaluaciones + gráfico de evolución lado a lado.
class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isTablet = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
    final patientAsync = ref.watch(_patientByIdProvider(patientId));
    final evaluationsAsync = ref.watch(patientEvaluationsProvider(patientId));

    Widget buildTitle() => patientAsync.maybeWhen(
      data: (p) => Text(p?.alias ?? l10n.patientsTitle),
      orElse: () => Text(l10n.patientsTitle),
    );

    Widget buildActions() => patientAsync.maybeWhen(
      data: (p) {
        if (p == null) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.patientEditTitle,
              onPressed: () async {
                await PatientEditDialog.show(context, initial: p);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deletePatientConfirmTitle,
              onPressed: () => _confirmDeletePatient(context, ref, p),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );

    Widget buildBody() => patientAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(failureMessage(e, l10n)),
        ),
      ),
      data: (patient) {
        if (patient == null) {
          return Center(child: Text(l10n.patientNotFound));
        }
        return evaluationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(failureMessage(e, l10n)),
            ),
          ),
          data: (evals) {
            if (isTablet) {
              return Row(
                children: [
                  SizedBox(
                    width: 380,
                    child: _EvaluationsTab(
                      patient: patient,
                      evaluations: evals,
                      patientId: patientId,
                    ),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            l10n.evolutionTab,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: PatientEvolutionChart(evaluations: evals),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return TabBarView(
              children: [
                _EvaluationsTab(
                  patient: patient,
                  evaluations: evals,
                  patientId: patientId,
                ),
                PatientEvolutionChart(evaluations: evals),
              ],
            );
          },
        );
      },
    );

    if (isTablet) {
      return Scaffold(
        appBar: AppBar(title: buildTitle(), actions: [buildActions()]),
        body: buildBody(),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: buildTitle(),
          actions: [buildActions()],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.evaluationsHeader),
              Tab(text: l10n.evolutionTab),
            ],
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  Future<void> _confirmDeletePatient(
    BuildContext context,
    WidgetRef ref,
    Patient patient,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePatientConfirmTitle),
        content: Text(l10n.deletePatientConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(patientsControllerProvider.notifier).delete(patient.id);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.deletePatientSuccessMessage)));
  }
}

final _patientByIdProvider = FutureProvider.autoDispose
    .family<Patient?, String>(
      (ref, id) => ref.watch(patientRepositoryProvider).findById(id),
    );

enum _EvalSort { newestFirst, oldestFirst, byScale }

class _EvaluationsTab extends StatefulWidget {
  const _EvaluationsTab({
    required this.patient,
    required this.evaluations,
    required this.patientId,
  });

  final Patient patient;
  final List<Evaluation> evaluations;
  final String patientId;

  @override
  State<_EvaluationsTab> createState() => _EvaluationsTabState();
}

class _EvaluationsTabState extends State<_EvaluationsTab> {
  _EvalSort _sort = _EvalSort.newestFirst;

  List<Evaluation> get _sorted {
    final evals = [...widget.evaluations];
    switch (_sort) {
      case _EvalSort.newestFirst:
        evals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _EvalSort.oldestFirst:
        evals.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _EvalSort.byScale:
        evals.sort((a, b) {
          final sc = a.scaleType.compareTo(b.scaleType);
          return sc != 0 ? sc : b.createdAt.compareTo(a.createdAt);
        });
    }
    return evals;
  }

  List<Widget> _buildGrouped(List<Evaluation> evals) {
    final groups = <String, List<Evaluation>>{};
    for (final e in evals) {
      groups.putIfAbsent(e.scaleType, () => []).add(e);
    }
    final result = <Widget>[];
    for (final entry in groups.entries) {
      result.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            entry.key.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );
      result.addAll(
        entry.value.map(
          (e) => _EvaluationTile(eval: e, patientId: widget.patientId),
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = _sorted;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PatientHeader(patient: widget.patient),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.evaluationsHeader,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (widget.evaluations.isNotEmpty)
          SegmentedButton<_EvalSort>(
            segments: [
              ButtonSegment(
                value: _EvalSort.newestFirst,
                label: Text(l10n.evalSortNewest),
              ),
              ButtonSegment(
                value: _EvalSort.oldestFirst,
                label: Text(l10n.evalSortOldest),
              ),
              ButtonSegment(
                value: _EvalSort.byScale,
                label: Text(l10n.evalSortByScale),
              ),
            ],
            selected: {_sort},
            onSelectionChanged: (s) => setState(() => _sort = s.first),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (widget.evaluations.isEmpty)
          const _NoEvaluationsCard()
        else if (_sort == _EvalSort.byScale)
          ..._buildGrouped(sorted)
        else
          ...sorted.map(
            (e) => _EvaluationTile(eval: e, patientId: widget.patientId),
          ),
      ],
    );
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PatientAvatar(patient: patient, radius: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    patient.alias,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (patient.notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                patient.notes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.patientCreatedOn(_formatDate(patient.createdAt)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoEvaluationsCard extends StatelessWidget {
  const _NoEvaluationsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            context.l10n.patientNoEvaluations,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Returns (accentForeground, accentSurface) for a given scale type,
/// consistent with the ScalesTabScreen card colours.
(Color, Color) _scaleAccent(
  String scaleType,
  ClinicalColors c,
  ColorScheme s,
) => switch (scaleType) {
  'gcs' => (c.info.foreground, c.info.surface),
  'nihss' => (c.danger.foreground, c.danger.surface),
  'abcd2' => (c.warning.foreground, c.warning.surface),
  'barthel' => (c.success.foreground, c.success.surface),
  _ => (s.onSecondaryContainer, s.secondaryContainer),
};

class _EvaluationTile extends ConsumerWidget {
  const _EvaluationTile({required this.eval, required this.patientId});

  final Evaluation eval;
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasNotes = eval.caseDescription.trim().isNotEmpty;
    final clinical = Theme.of(context).clinicalColors;
    final scheme = Theme.of(context).colorScheme;
    final (accentFg, accentSurface) = _scaleAccent(
      eval.scaleType,
      clinical,
      scheme,
    );
    final severity = kInterpSeverity[eval.interpretation];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left accent strip ────────────────────────────────────────
            Container(width: 4, color: accentFg),
            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scale chip
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentSurface,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Text(
                          eval.scaleType.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: accentFg,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Score + interpretation + date + notes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${eval.totalScore} — ${context.l10n.resolveKey(eval.interpretation)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (severity != null) ...[
                                const SizedBox(width: 6),
                                SeverityDot(severity: severity),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            _formatDate(eval.createdAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (hasNotes) ...[
                            const SizedBox(height: 6),
                            Text(
                              eval.caseDescription,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Delete — visually separated at the far right
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      tooltip: l10n.deleteEvaluationButton,
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(evaluationRepositoryProvider).delete(eval.id);

    if (!context.mounted) return;
    ref.invalidate(patientEvaluationsProvider(patientId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.deleteSuccessMessage)));
  }
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
