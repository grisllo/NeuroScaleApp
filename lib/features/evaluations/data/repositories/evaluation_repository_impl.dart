import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../datasources/evaluations_local_datasource.dart';
import '../datasources/supabase_evaluation_datasource.dart';
import '../models/evaluation_model.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  const EvaluationRepositoryImpl({
    required SupabaseEvaluationDatasource remote,
    required EvaluationsLocalDatasource local,
  }) : _remote = remote,
       _local = local;

  final SupabaseEvaluationDatasource _remote;
  final EvaluationsLocalDatasource _local;

  @override
  Future<void> save(Evaluation evaluation) async {
    try {
      final model = EvaluationModel.fromEntity(evaluation);
      await _remote.save(model);
      await _local.cacheOne(model);
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }

  @override
  Future<List<Evaluation>> fetchAll(
    String userId, {
    Set<String> scales = const {},
    DateTime? dateFrom,
    DateTime? dateTo,
    String searchQuery = '',
    int page = 0,
    int pageSize = kEvaluationsPageSize,
    String? patientId,
  }) async {
    try {
      final models = await _remote.fetchAll(
        userId,
        scales: scales,
        dateFrom: dateFrom,
        dateTo: dateTo,
        searchQuery: searchQuery,
        page: page,
        pageSize: pageSize,
        patientId: patientId,
      );
      // Cache in background — fast local write, fire & forget.
      _local.cacheAll(models).ignore();
      return models;
    } on AppException catch (e) {
      // Remote failed — serve from local cache.
      try {
        return await _local.fetchAll(
          userId,
          scales: scales,
          dateFrom: dateFrom,
          dateTo: dateTo,
          searchQuery: searchQuery,
          page: page,
          pageSize: pageSize,
          patientId: patientId,
        );
      } on CacheException {
        throw UnexpectedFailure(e.message);
      }
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
