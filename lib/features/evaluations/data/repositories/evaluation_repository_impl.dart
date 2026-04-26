import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../datasources/supabase_evaluation_datasource.dart';
import '../models/evaluation_model.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  const EvaluationRepositoryImpl(this._datasource);

  final SupabaseEvaluationDatasource _datasource;

  @override
  Future<void> save(Evaluation evaluation) async {
    try {
      await _datasource.save(EvaluationModel.fromEntity(evaluation));
    } on AppException catch (e) {
      throw UnexpectedFailure(e.message);
    }
  }
}
