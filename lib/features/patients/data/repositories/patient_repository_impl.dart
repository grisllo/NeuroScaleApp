import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/supabase_patient_datasource.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  const PatientRepositoryImpl(this._datasource);

  final SupabasePatientDatasource _datasource;

  @override
  Future<List<Patient>> fetchAll(
    String userId, {
    String searchQuery = '',
  }) async {
    try {
      return await _datasource.fetchAll(userId, searchQuery: searchQuery);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<Patient?> findById(String id) async {
    try {
      return await _datasource.findById(id);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<Patient> create(Patient draft) async {
    try {
      return await _datasource.create(PatientModel.fromEntity(draft));
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<Patient> update(Patient patient) async {
    try {
      return await _datasource.update(PatientModel.fromEntity(patient));
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _datasource.delete(id);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }
}
