import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/evaluation_model.dart';

class EvaluationsLocalDatasource {
  const EvaluationsLocalDatasource(this._db);

  final AppDatabase? _db;

  EvaluationsDao get _dao {
    final db = _db;
    if (db == null) throw const CacheException('Offline cache unavailable');
    return db.evaluationsDao;
  }

  Future<void> cacheAll(List<EvaluationModel> models) async {
    if (_db == null) return;
    await _dao.upsertMany(models.map(_toCompanion).toList());
  }

  Future<void> cacheOne(EvaluationModel model) async {
    if (_db == null) return;
    await _dao.upsertOne(_toCompanion(model));
  }

  Future<List<EvaluationModel>> fetchAll(
    String userId, {
    Set<String> scales = const {},
    DateTime? dateFrom,
    DateTime? dateTo,
    String searchQuery = '',
    int page = 0,
    int pageSize = 20,
    String? patientId,
  }) async {
    final rows = await _dao.getByUserId(userId);
    var result = rows.map(_fromRow).toList();

    if (scales.isNotEmpty) {
      result = result.where((e) => scales.contains(e.scaleType)).toList();
    }
    if (dateFrom != null) {
      result = result.where((e) => !e.createdAt.isBefore(dateFrom)).toList();
    }
    if (dateTo != null) {
      result = result.where((e) => !e.createdAt.isAfter(dateTo)).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result =
          result.where((e) => e.caseDescription.toLowerCase().contains(q)).toList();
    }
    if (patientId != null) {
      result = result.where((e) => e.patientId == patientId).toList();
    }

    final start = page * pageSize;
    if (start >= result.length) return [];
    return result.skip(start).take(pageSize).toList();
  }

  Future<void> removeOne(String id) async {
    if (_db == null) return;
    await _dao.removeById(id);
  }

  static EvaluationsCompanion _toCompanion(EvaluationModel m) =>
      EvaluationsCompanion.insert(
        id: m.id,
        userId: m.userId,
        scaleType: m.scaleType,
        scaleVersion: m.scaleVersion,
        caseDescription: m.caseDescription,
        totalScore: m.totalScore,
        interpretation: m.interpretation,
        detailedScores: jsonEncode(m.detailedScores),
        patientId: Value(m.patientId),
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );

  static EvaluationModel _fromRow(EvaluationRow row) => EvaluationModel(
        id: row.id,
        userId: row.userId,
        scaleType: row.scaleType,
        scaleVersion: row.scaleVersion,
        caseDescription: row.caseDescription,
        totalScore: row.totalScore,
        interpretation: row.interpretation,
        detailedScores: Map<String, dynamic>.from(
          jsonDecode(row.detailedScores) as Map,
        ),
        patientId: row.patientId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
