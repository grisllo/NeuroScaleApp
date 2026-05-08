import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
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

  Future<List<EvaluationModel>> fetchAll(
    String userId, {
    Set<String> scales = const {},
    DateTime? dateFrom,
    DateTime? dateTo,
    String searchQuery = '',
    int page = 0,
    int pageSize = kEvaluationsPageSize,
    String? patientId,
  }) async {
    try {
      var query = _client
          .from('evaluations')
          .select(
            'id,user_id,scale_type,scale_version,total_score,interpretation,created_at,updated_at,patient_id',
          )
          .eq('user_id', userId);

      if (scales.isNotEmpty) {
        query = query.inFilter('scale_type', scales.toList());
      }
      if (dateFrom != null) {
        query = query.gte('created_at', dateFrom.toIso8601String());
      }
      if (dateTo != null) {
        // Include the full end day
        final endOfDay = DateTime(
          dateTo.year,
          dateTo.month,
          dateTo.day,
          23,
          59,
          59,
        );
        query = query.lte('created_at', endOfDay.toIso8601String());
      }
      if (searchQuery.isNotEmpty) {
        query = query.ilike('case_description', '%$searchQuery%');
      }
      if (patientId != null) {
        if (patientId.isEmpty) {
          query = query.isFilter('patient_id', null);
        } else {
          query = query.eq('patient_id', patientId);
        }
      }

      final rows = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

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
