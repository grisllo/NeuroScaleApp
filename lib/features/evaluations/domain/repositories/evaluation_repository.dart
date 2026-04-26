import '../entities/evaluation.dart';

abstract class EvaluationRepository {
  Future<void> save(Evaluation evaluation);
}
