import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/evaluation_model.dart';

class SupabaseEvaluationDatasource {
  const SupabaseEvaluationDatasource(this._client);

  final SupabaseClient _client;

  Future<void> save(EvaluationModel model) async {
    try {
      await _client.from('evaluations').insert(model.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
