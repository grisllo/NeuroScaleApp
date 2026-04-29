import '../entities/patient.dart';
import '../repositories/patient_repository.dart';

class FetchPatientsUseCase {
  const FetchPatientsUseCase(this._repository);

  final PatientRepository _repository;

  Future<List<Patient>> call(String userId, {String searchQuery = ''}) =>
      _repository.fetchAll(userId, searchQuery: searchQuery);
}
