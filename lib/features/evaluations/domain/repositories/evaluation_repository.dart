import '../entities/evaluation.dart';

abstract class EvaluationRepository {
  Future<void> save(Evaluation evaluation);
  Future<List<Evaluation>> fetchAll(
    String userId, {
    Set<String> scales,
    DateTime? dateFrom,
    DateTime? dateTo,
    String searchQuery,
    int page,
    int pageSize,
  });
  Future<void> delete(String id);
}
