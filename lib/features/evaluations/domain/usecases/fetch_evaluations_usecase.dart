import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';

class FetchEvaluationsUseCase {
  const FetchEvaluationsUseCase(this._repository);

  final EvaluationRepository _repository;

  Future<List<Evaluation>> call(String userId) =>
      _repository.fetchAll(userId);
}
