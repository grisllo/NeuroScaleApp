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

    /// When non-null:
    ///   - empty string '' → filter to evaluations with patient_id IS NULL.
    ///   - non-empty string → filter to evaluations.patient_id = patientId.
    /// When null → no filter (returns all).
    String? patientId,
  });
  Future<void> delete(String id);
}
