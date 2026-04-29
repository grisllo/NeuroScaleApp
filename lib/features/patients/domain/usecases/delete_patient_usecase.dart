import '../repositories/patient_repository.dart';

class DeletePatientUseCase {
  const DeletePatientUseCase(this._repository);

  final PatientRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
