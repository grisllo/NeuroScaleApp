import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/animated_tap_scale.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_skeleton.dart';
import '../../domain/entities/patient.dart';
import '../providers/patients_controller.dart';
import '../widgets/patient_edit_dialog.dart';

// Paleta de fondos para avatares — todos con contraste suficiente para texto blanco.
const _kAvatarPalette = [
  Color(0xFF1565C0), // blue
  Color(0xFF2E7D32), // green
  Color(0xFF6A1B9A), // purple
  Color(0xFFAD1457), // pink
  Color(0xFF00695C), // teal
  Color(0xFF4527A0), // deep purple
  Color(0xFF0277BD), // light blue
  Color(0xFF558B2F), // light green
  Color(0xFF5D4037), // brown
  Color(0xFF00838F), // cyan
];

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

    final isTablet = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: Column(
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
                  loading: () => const AppLoadingSkeleton(),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(e.toString()),
                    ),
                  ),
                  data: (patients) {
                    if (patients.isEmpty) {
                      final hasQuery = _searchController.text.isNotEmpty;
                      return AppEmptyState(
                        icon: hasQuery
                            ? Icons.search_off_outlined
                            : Icons.people_outline,
                        title: hasQuery
                            ? l10n.patientsSearchEmpty
                            : l10n.patientsEmptyTitle,
                        subtitle: hasQuery ? null : l10n.patientsEmptySubtitle,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: patients.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _PatientCard(patient: patients[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPatient,
        icon: const Icon(Icons.add),
        label: Text(l10n.patientNewButton),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final trimmed = patient.alias.trim();
    final initials = trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.toUpperCase();
    final avatarColor =
        _kAvatarPalette[patient.id.hashCode.abs() % _kAvatarPalette.length];

    return AnimatedTapScale(
      onTap: () => context.pushNamed(
        'patient-detail',
        pathParameters: {'id': patient.id},
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.alias,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (patient.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        patient.notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
