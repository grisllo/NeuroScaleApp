import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ── Tables ────────────────────────────────────────────────────────────────────

@DataClassName('EvaluationRow')
class Evaluations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get scaleType => text()();
  IntColumn get scaleVersion => integer()();
  TextColumn get caseDescription => text()();
  IntColumn get totalScore => integer()();
  TextColumn get interpretation => text()();
  // Stored as JSON string.
  TextColumn get detailedScores => text()();
  TextColumn get patientId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PatientRow')
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get alias => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── DAOs ──────────────────────────────────────────────────────────────────────

@DriftAccessor(tables: [Evaluations])
class EvaluationsDao extends DatabaseAccessor<AppDatabase>
    with _$EvaluationsDaoMixin {
  EvaluationsDao(super.db);

  Future<List<EvaluationRow>> getByUserId(String userId) => (select(evaluations)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  Future<void> upsertMany(List<EvaluationsCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(evaluations, rows));

  Future<void> upsertOne(EvaluationsCompanion row) =>
      into(evaluations).insertOnConflictUpdate(row);

  Future<int> removeById(String id) =>
      (delete(evaluations)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Patients])
class PatientsDao extends DatabaseAccessor<AppDatabase>
    with _$PatientsDaoMixin {
  PatientsDao(super.db);

  Future<List<PatientRow>> getByUserId(String userId) => (select(patients)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([(t) => OrderingTerm.asc(t.alias)]))
      .get();

  Future<PatientRow?> getById(String id) =>
      (select(patients)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertMany(List<PatientsCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(patients, rows));

  Future<void> upsertOne(PatientsCompanion row) =>
      into(patients).insertOnConflictUpdate(row);

  Future<int> removeById(String id) =>
      (delete(patients)..where((t) => t.id.equals(id))).go();
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [Evaluations, Patients],
  daos: [EvaluationsDao, PatientsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'neuroscale_db'));

  @override
  int get schemaVersion => 1;
}
