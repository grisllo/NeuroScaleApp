import '../../../../core/errors/failures.dart';
import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';

class SaveEvaluationUseCase {
  const SaveEvaluationUseCase(this._repository);

  final EvaluationRepository _repository;

  Future<void> call(Evaluation evaluation) {
    if (evaluation.caseDescription.trim().isEmpty) {
      throw const ValidationFailure(
        'La descripción del caso no puede estar vacía.',
      );
    }
    return _repository.save(evaluation);
  }
}
