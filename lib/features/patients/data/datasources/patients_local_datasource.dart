import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/patient_model.dart';

class PatientsLocalDatasource {
  const PatientsLocalDatasource(this._db);

  final AppDatabase? _db;

  PatientsDao get _dao {
    final db = _db;
    if (db == null) throw const CacheException('Offline cache unavailable');
    return db.patientsDao;
  }

  Future<void> cacheAll(List<PatientModel> models) async {
    if (_db == null) return;
    await _dao.upsertMany(models.map(_toCompanion).toList());
  }

  Future<void> cacheOne(PatientModel model) async {
    if (_db == null) return;
    await _dao.upsertOne(_toCompanion(model));
  }

  Future<List<PatientModel>> fetchAll(
    String userId, {
    String searchQuery = '',
  }) async {
    final rows = await _dao.getByUserId(userId);
    var result = rows.map(_fromRow).toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result =
          result.where((p) => p.alias.toLowerCase().contains(q)).toList();
    }

    return result;
  }

  Future<PatientModel?> findById(String id) async {
    final row = await _dao.getById(id);
    return row != null ? _fromRow(row) : null;
  }

  Future<void> removeOne(String id) async {
    if (_db == null) return;
    await _dao.removeById(id);
  }

  static PatientsCompanion _toCompanion(PatientModel m) =>
      PatientsCompanion.insert(
        id: m.id,
        userId: m.userId,
        alias: m.alias,
        notes: Value(m.notes),
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );

  static PatientModel _fromRow(PatientRow row) => PatientModel(
        id: row.id,
        userId: row.userId,
        alias: row.alias,
        notes: row.notes ?? '',
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
