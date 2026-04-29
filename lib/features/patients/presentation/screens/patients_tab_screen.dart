import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../domain/entities/patient.dart';
import '../providers/patients_controller.dart';
import '../widgets/patient_edit_dialog.dart';

class PatientsTabScreen extends ConsumerStatefulWidget {
  const PatientsTabScreen({super.key});

  @override
  ConsumerState<PatientsTabScreen> createState() => _PatientsTabScreenState();
}

class _PatientsTabScreenState extends ConsumerState<PatientsTabScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(patientsControllerProvider.notifier).setSearchQuery(value);
    });
  }

  Future<void> _createPatient() async {
    await PatientEditDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final patientsAsync = ref.watch(patientsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.patientsSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: patientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(e.toString()),
                ),
              ),
              data: (patients) {
                if (patients.isEmpty) {
                  return _EmptyState(
                    hasSearchQuery: _searchController.text.isNotEmpty,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: patients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _PatientCard(patient: patients[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPatient,
        icon: const Icon(Icons.add),
        label: Text(l10n.patientNewButton),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearchQuery});

  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off_outlined : Icons.people_outline,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              hasSearchQuery
                  ? l10n.patientsSearchEmpty
                  : l10n.patientsEmptyTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (!hasSearchQuery) ...[
              const SizedBox(height: 8),
              Text(
                l10n.patientsEmptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          patient.alias,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: patient.notes.isNotEmpty
            ? Text(
                patient.notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.pushNamed(
          'patient-detail',
          pathParameters: {'id': patient.id},
        ),
      ),
    );
  }
}
