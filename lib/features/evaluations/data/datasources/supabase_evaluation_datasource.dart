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

  Future<List<EvaluationModel>> fetchAll(String userId) async {
    try {
      final rows = await _client
          .from('evaluations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.map(EvaluationModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('evaluations').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
