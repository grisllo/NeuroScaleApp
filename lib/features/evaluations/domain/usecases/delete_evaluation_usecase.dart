import '../repositories/evaluation_repository.dart';

class DeleteEvaluationUseCase {
  const DeleteEvaluationUseCase(this._repository);

  final EvaluationRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
