import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/scale_key_resolver.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../evaluations/domain/entities/evaluation.dart';
import '../../../evaluations/presentation/providers/evaluation_provider.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_provider.dart';
import '../providers/patients_controller.dart';
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
          child: Text(e.toString()),
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
              child: Text(e.toString()),
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
                  Expanded(child: PatientEvolutionChart(evaluations: evals)),
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
              Tab(text: l10n.listTab),
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

class _EvaluationsTab extends StatelessWidget {
  const _EvaluationsTab({
    required this.patient,
    required this.evaluations,
    required this.patientId,
  });

  final Patient patient;
  final List<Evaluation> evaluations;
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PatientHeader(patient: patient),
        const SizedBox(height: 16),
        Text(
          context.l10n.evaluationsHeader,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (evaluations.isEmpty)
          const _NoEvaluationsCard()
        else
          ...evaluations.map(
            (e) => _EvaluationTile(eval: e, patientId: patientId),
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
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
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
              const SizedBox(height: 12),
              Text(
                patient.notes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
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

class _EvaluationTile extends ConsumerWidget {
  const _EvaluationTile({required this.eval, required this.patientId});

  final Evaluation eval;
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasNotes = eval.caseDescription.trim().isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Chip(
                label: Text(eval.scaleType.toUpperCase()),
                padding: EdgeInsets.zero,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${eval.totalScore} — ${context.l10n.resolveKey(eval.interpretation)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(eval.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.deleteEvaluationButton,
              onPressed: () => _confirmDelete(context, ref),
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
