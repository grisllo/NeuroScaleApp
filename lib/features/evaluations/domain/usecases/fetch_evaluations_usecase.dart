import '../../../../core/constants/app_constants.dart';
import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';

class FetchEvaluationsUseCase {
  const FetchEvaluationsUseCase(this._repository);

  final EvaluationRepository _repository;

  Future<List<Evaluation>> call(
    String userId, {
    Set<String> scales = const {},
    DateTime? dateFrom,
    DateTime? dateTo,
    String searchQuery = '',
    int page = 0,
    int pageSize = kEvaluationsPageSize,
    String? patientId,
  }) => _repository.fetchAll(
    userId,
    scales: scales,
    dateFrom: dateFrom,
    dateTo: dateTo,
    searchQuery: searchQuery,
    page: page,
    pageSize: pageSize,
    patientId: patientId,
  );
}
