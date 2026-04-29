import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../evaluations/domain/entities/evaluation.dart';
import '../../domain/entities/patient.dart';
import '../providers/patient_provider.dart';
import '../providers/patients_controller.dart';
import '../widgets/patient_edit_dialog.dart';

/// Detail screen for a single patient. Shows header + evaluations list.
/// Evolution chart is delivered in subfase 3.3.
class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final patientAsync = ref.watch(_patientByIdProvider(patientId));
    final evaluationsAsync = ref.watch(patientEvaluationsProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: patientAsync.maybeWhen(
          data: (p) => Text(p?.alias ?? l10n.patientsTitle),
          orElse: () => Text(l10n.patientsTitle),
        ),
        actions: [
          patientAsync.maybeWhen(
            data: (p) => p != null
                ? IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      await PatientEditDialog.show(context, initial: p);
                    },
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: patientAsync.when(
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PatientHeader(patient: patient),
              const SizedBox(height: 16),
              Text(
                l10n.evaluationsHeader,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              evaluationsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(e.toString()),
                ),
                data: (evals) => evals.isEmpty
                    ? const _NoEvaluationsCard()
                    : Column(
                        children:
                            evals.map((e) => _EvaluationTile(eval: e)).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Provider para obtener un paciente por id (autoDispose).
final _patientByIdProvider =
    FutureProvider.autoDispose.family<Patient?, String>(
  (ref, id) => ref.watch(patientRepositoryProvider).findById(id),
);

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
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
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
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            l10n.patientNoEvaluations,
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

class _EvaluationTile extends StatelessWidget {
  const _EvaluationTile({required this.eval});

  final Evaluation eval;

  @override
  Widget build(BuildContext context) {
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
                    '${eval.totalScore} — ${eval.interpretation}',
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
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
