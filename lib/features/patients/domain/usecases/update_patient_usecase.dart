import '../../../../core/errors/failures.dart';
import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class UpdatePatientUseCase {
  const UpdatePatientUseCase(this._repository);

  final PatientRepository _repository;

  Future<Patient> call(Patient patient) {
    if (patient.alias.trim().isEmpty) {
      throw const ValidationFailure(
        'El alias del paciente no puede estar vacío.',
      );
    }
    return _repository.update(patient);
  }
}
