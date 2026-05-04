import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/evaluations_local_datasource.dart';
import '../../data/datasources/supabase_evaluation_datasource.dart';
import '../../data/repositories/evaluation_repository_impl.dart';
import '../../domain/repositories/evaluation_repository.dart';

final _evaluationDatasourceProvider = Provider<SupabaseEvaluationDatasource>(
  (ref) => SupabaseEvaluationDatasource(ref.watch(supabaseClientProvider)),
);

final _evaluationsLocalDatasourceProvider =
    Provider<EvaluationsLocalDatasource>(
      (ref) => EvaluationsLocalDatasource(ref.watch(appDatabaseProvider)),
    );

final evaluationRepositoryProvider = Provider<EvaluationRepository>(
  (ref) => EvaluationRepositoryImpl(
    remote: ref.watch(_evaluationDatasourceProvider),
    local: ref.watch(_evaluationsLocalDatasourceProvider),
  ),
);
