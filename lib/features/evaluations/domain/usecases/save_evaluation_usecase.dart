import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';

class SaveEvaluationUseCase {
  const SaveEvaluationUseCase(this._repository);

  final EvaluationRepository _repository;

  /// case_description is now optional — patient_id (when set) provides the
  /// primary identification of the evaluation. Both can be null/empty.
  Future<void> call(Evaluation evaluation) => _repository.save(evaluation);
}
