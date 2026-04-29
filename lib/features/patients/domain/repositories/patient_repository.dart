import '../entities/patient.dart';

abstract class PatientRepository {
  Future<List<Patient>> fetchAll(String userId, {String searchQuery = ''});
  Future<Patient?> findById(String id);

  /// Creates a new patient. Pass a draft Patient with empty `id` and timestamps;
  /// returns the created Patient with server-assigned id and timestamps.
  Future<Patient> create(Patient draft);

  Future<Patient> update(Patient patient);
  Future<void> delete(String id);
}
