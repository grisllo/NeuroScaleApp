import '../../../../core/errors/failures.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class CreatePatientUseCase {
  const CreatePatientUseCase(this._repository);

  final PatientRepository _repository;

  /// Creates a new patient. Validates that `alias` is non-empty.
  Future<Patient> call({
    required String userId,
    required String alias,
    String notes = '',
  }) {
    if (alias.trim().isEmpty) {
      throw const ValidationFailure(
        'El alias del paciente no puede estar vacío.',
      );
    }
    final now = DateTime.now();
    final draft = Patient(
      id: '',
      userId: userId,
      alias: alias.trim(),
      notes: notes.trim(),
      createdAt: now,
      updatedAt: now,
    );
    return _repository.create(draft);
  }
}
