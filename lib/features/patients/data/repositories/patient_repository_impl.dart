import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patients_local_datasource.dart';
import '../datasources/supabase_patient_datasource.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  const PatientRepositoryImpl({
    required SupabasePatientDatasource remote,
    required PatientsLocalDatasource local,
  }) : _remote = remote,
       _local = local;

  final SupabasePatientDatasource _remote;
  final PatientsLocalDatasource _local;

  @override
  Future<List<Patient>> fetchAll(
    String userId, {
    String searchQuery = '',
  }) async {
    try {
      final models = await _remote.fetchAll(userId, searchQuery: searchQuery);
      _local.cacheAll(models).ignore();
      return models;
    } on AppException catch (e) {
      try {
        return await _local.fetchAll(userId, searchQuery: searchQuery);
      } on CacheException {
        throw UnexpectedFailure(e.message);
      }
    }
  }

  @override
  Future<Patient?> findById(String id) async {
    try {
      final model = await _remote.findById(id);
      if (model != null) _local.cacheOne(model).ignore();
      return model;
    } on AppException catch (e) {
      try {
        return await _local.findById(id);
      } on CacheException {
        throw UnexpectedFailure(e.message);
      }
    }
  }

  @override
  Future<Patient> create(Patient draft) async {
    try {
      final created = await _remote.create(PatientModel.fromEntity(draft));
      _local.cacheOne(created).ignore();
      return created;
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<Patient> update(Patient patient) async {
    try {
      final updated = await _remote.update(PatientModel.fromEntity(patient));
      _local.cacheOne(updated).ignore();
      return updated;
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remote.delete(id);
      _local.removeOne(id).ignore();
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }
}
