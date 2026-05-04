import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/session_provider.dart';
import '../../../evaluations/domain/entities/evaluation.dart';
import '../../../evaluations/domain/usecases/fetch_evaluations_usecase.dart';
import '../../../evaluations/presentation/providers/evaluation_provider.dart';
import '../../domain/entities/patient.dart';
import '../../domain/usecases/create_patient_usecase.dart';
import '../../domain/usecases/delete_patient_usecase.dart';
import '../../domain/usecases/fetch_patients_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';
import 'patient_provider.dart';

class PatientsController extends AsyncNotifier<List<Patient>> {
  String _searchQuery = '';

  // Search/filter metadata kept as private state with a read-only getter.
  // ignore: avoid_public_notifier_properties
  String get searchQuery => _searchQuery;

  @override
  FutureOr<List<Patient>> build() => _fetch();

  Future<List<Patient>> _fetch() async {
    final userId = ref.read(sessionProvider).asData?.value?.id ?? '';
    if (userId.isEmpty) return const [];
    return FetchPatientsUseCase(
      ref.read(patientRepositoryProvider),
    ).call(userId, searchQuery: _searchQuery);
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query.trim();
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Patient> create({required String alias, String notes = ''}) async {
    final userId = ref.read(sessionProvider).asData?.value?.id ?? '';
    final patient = await CreatePatientUseCase(
      ref.read(patientRepositoryProvider),
    ).call(userId: userId, alias: alias, notes: notes);
    state = AsyncData([patient, ...?state.value]);
    return patient;
  }

  Future<Patient> updatePatient(Patient patient) async {
    final updated = await UpdatePatientUseCase(
      ref.read(patientRepositoryProvider),
    ).call(patient);
    final current = state.value ?? [];
    state = AsyncData(
      current.map((p) => p.id == updated.id ? updated : p).toList(),
    );
    return updated;
  }

  Future<void> delete(String id) async {
    await DeletePatientUseCase(ref.read(patientRepositoryProvider)).call(id);
    final current = state.value ?? [];
    state = AsyncData(current.where((p) => p.id != id).toList());
  }
}

final patientsControllerProvider =
    AsyncNotifierProvider<PatientsController, List<Patient>>(
      PatientsController.new,
    );

/// Evaluations for a given patient (autoDispose family). Used by detail screen.
final patientEvaluationsProvider = FutureProvider.autoDispose
    .family<List<Evaluation>, String>((ref, patientId) {
      final userId = ref.watch(sessionProvider).asData?.value?.id ?? '';
      if (userId.isEmpty) return Future.value(const []);
      return FetchEvaluationsUseCase(
        ref.watch(evaluationRepositoryProvider),
      ).call(userId, patientId: patientId, pageSize: 100);
    });
