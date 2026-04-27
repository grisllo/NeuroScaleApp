import '../entities/evaluation.dart';

abstract class EvaluationRepository {
  Future<void> save(Evaluation evaluation);
  Future<List<Evaluation>> fetchAll(String userId);
  Future<void> delete(String id);
}
