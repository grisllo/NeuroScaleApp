import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/patient_model.dart';

class SupabasePatientDatasource {
  const SupabasePatientDatasource(this._client);

  final SupabaseClient _client;

  Future<List<PatientModel>> fetchAll(
    String userId, {
    String searchQuery = '',
  }) async {
    try {
      var query = _client.from('patients').select().eq('user_id', userId);

      if (searchQuery.isNotEmpty) {
        query = query.ilike('alias', '%$searchQuery%');
      }

      final rows = await query.order('created_at', ascending: false);
      return rows.map(PatientModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PatientModel?> findById(String id) async {
    try {
      final row =
          await _client.from('patients').select().eq('id', id).maybeSingle();
      if (row == null) return null;
      return PatientModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PatientModel> create(PatientModel draft) async {
    try {
      final row = await _client
          .from('patients')
          .insert(draft.toInsertJson())
          .select()
          .single();
      return PatientModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<PatientModel> update(PatientModel patient) async {
    try {
      final row = await _client
          .from('patients')
          .update(patient.toUpdateJson())
          .eq('id', patient.id)
          .select()
          .single();
      return PatientModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from('patients').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
