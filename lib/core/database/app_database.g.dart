// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$EvaluationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $EvaluationsTable get evaluations => attachedDatabase.evaluations;
}
mixin _$PatientsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
}

class $EvaluationsTable extends Evaluations
    with TableInfo<$EvaluationsTable, EvaluationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvaluationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scaleTypeMeta =
      const VerificationMeta('scaleType');
  @override
  late final GeneratedColumn<String> scaleType = GeneratedColumn<String>(
      'scale_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scaleVersionMeta =
      const VerificationMeta('scaleVersion');
  @override
  late final GeneratedColumn<int> scaleVersion = GeneratedColumn<int>(
      'scale_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _caseDescriptionMeta =
      const VerificationMeta('caseDescription');
  @override
  late final GeneratedColumn<String> caseDescription = GeneratedColumn<String>(
      'case_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalScoreMeta =
      const VerificationMeta('totalScore');
  @override
  late final GeneratedColumn<int> totalScore = GeneratedColumn<int>(
      'total_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _interpretationMeta =
      const VerificationMeta('interpretation');
  @override
  late final GeneratedColumn<String> interpretation = GeneratedColumn<String>(
      'interpretation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailedScoresMeta =
      const VerificationMeta('detailedScores');
  @override
  late final GeneratedColumn<String> detailedScores = GeneratedColumn<String>(
      'detailed_scores', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        scaleType,
        scaleVersion,
        caseDescription,
        totalScore,
        interpretation,
        detailedScores,
        patientId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evaluations';
  @override
  VerificationContext validateIntegrity(Insertable<EvaluationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('scale_type')) {
      context.handle(_scaleTypeMeta,
          scaleType.isAcceptableOrUnknown(data['scale_type']!, _scaleTypeMeta));
    } else if (isInserting) {
      context.missing(_scaleTypeMeta);
    }
    if (data.containsKey('scale_version')) {
      context.handle(
          _scaleVersionMeta,
          scaleVersion.isAcceptableOrUnknown(
              data['scale_version']!, _scaleVersionMeta));
    } else if (isInserting) {
      context.missing(_scaleVersionMeta);
    }
    if (data.containsKey('case_description')) {
      context.handle(
          _caseDescriptionMeta,
          caseDescription.isAcceptableOrUnknown(
              data['case_description']!, _caseDescriptionMeta));
    } else if (isInserting) {
      context.missing(_caseDescriptionMeta);
    }
    if (data.containsKey('total_score')) {
      context.handle(
          _totalScoreMeta,
          totalScore.isAcceptableOrUnknown(
              data['total_score']!, _totalScoreMeta));
    } else if (isInserting) {
      context.missing(_totalScoreMeta);
    }
    if (data.containsKey('interpretation')) {
      context.handle(
          _interpretationMeta,
          interpretation.isAcceptableOrUnknown(
              data['interpretation']!, _interpretationMeta));
    } else if (isInserting) {
      context.missing(_interpretationMeta);
    }
    if (data.containsKey('detailed_scores')) {
      context.handle(
          _detailedScoresMeta,
          detailedScores.isAcceptableOrUnknown(
              data['detailed_scores']!, _detailedScoresMeta));
    } else if (isInserting) {
      context.missing(_detailedScoresMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvaluationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvaluationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      scaleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scale_type'])!,
      scaleVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scale_version'])!,
      caseDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}case_description'])!,
      totalScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_score'])!,
      interpretation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}interpretation'])!,
      detailedScores: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}detailed_scores'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EvaluationsTable createAlias(String alias) {
    return $EvaluationsTable(attachedDatabase, alias);
  }
}

class EvaluationRow extends DataClass implements Insertable<EvaluationRow> {
  final String id;
  final String userId;
  final String scaleType;
  final int scaleVersion;
  final String caseDescription;
  final int totalScore;
  final String interpretation;
  final String detailedScores;
  final String? patientId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EvaluationRow(
      {required this.id,
      required this.userId,
      required this.scaleType,
      required this.scaleVersion,
      required this.caseDescription,
      required this.totalScore,
      required this.interpretation,
      required this.detailedScores,
      this.patientId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['scale_type'] = Variable<String>(scaleType);
    map['scale_version'] = Variable<int>(scaleVersion);
    map['case_description'] = Variable<String>(caseDescription);
    map['total_score'] = Variable<int>(totalScore);
    map['interpretation'] = Variable<String>(interpretation);
    map['detailed_scores'] = Variable<String>(detailedScores);
    if (!nullToAbsent || patientId != null) {
      map['patient_id'] = Variable<String>(patientId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EvaluationsCompanion toCompanion(bool nullToAbsent) {
    return EvaluationsCompanion(
      id: Value(id),
      userId: Value(userId),
      scaleType: Value(scaleType),
      scaleVersion: Value(scaleVersion),
      caseDescription: Value(caseDescription),
      totalScore: Value(totalScore),
      interpretation: Value(interpretation),
      detailedScores: Value(detailedScores),
      patientId: patientId == null && nullToAbsent
          ? const Value.absent()
          : Value(patientId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EvaluationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvaluationRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      scaleType: serializer.fromJson<String>(json['scaleType']),
      scaleVersion: serializer.fromJson<int>(json['scaleVersion']),
      caseDescription: serializer.fromJson<String>(json['caseDescription']),
      totalScore: serializer.fromJson<int>(json['totalScore']),
      interpretation: serializer.fromJson<String>(json['interpretation']),
      detailedScores: serializer.fromJson<String>(json['detailedScores']),
      patientId: serializer.fromJson<String?>(json['patientId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'scaleType': serializer.toJson<String>(scaleType),
      'scaleVersion': serializer.toJson<int>(scaleVersion),
      'caseDescription': serializer.toJson<String>(caseDescription),
      'totalScore': serializer.toJson<int>(totalScore),
      'interpretation': serializer.toJson<String>(interpretation),
      'detailedScores': serializer.toJson<String>(detailedScores),
      'patientId': serializer.toJson<String?>(patientId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EvaluationRow copyWith(
          {String? id,
          String? userId,
          String? scaleType,
          int? scaleVersion,
          String? caseDescription,
          int? totalScore,
          String? interpretation,
          String? detailedScores,
          Value<String?> patientId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      EvaluationRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        scaleType: scaleType ?? this.scaleType,
        scaleVersion: scaleVersion ?? this.scaleVersion,
        caseDescription: caseDescription ?? this.caseDescription,
        totalScore: totalScore ?? this.totalScore,
        interpretation: interpretation ?? this.interpretation,
        detailedScores: detailedScores ?? this.detailedScores,
        patientId: patientId.present ? patientId.value : this.patientId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  EvaluationRow copyWithCompanion(EvaluationsCompanion data) {
    return EvaluationRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      scaleType: data.scaleType.present ? data.scaleType.value : this.scaleType,
      scaleVersion: data.scaleVersion.present
          ? data.scaleVersion.value
          : this.scaleVersion,
      caseDescription: data.caseDescription.present
          ? data.caseDescription.value
          : this.caseDescription,
      totalScore:
          data.totalScore.present ? data.totalScore.value : this.totalScore,
      interpretation: data.interpretation.present
          ? data.interpretation.value
          : this.interpretation,
      detailedScores: data.detailedScores.present
          ? data.detailedScores.value
          : this.detailedScores,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvaluationRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scaleType: $scaleType, ')
          ..write('scaleVersion: $scaleVersion, ')
          ..write('caseDescription: $caseDescription, ')
          ..write('totalScore: $totalScore, ')
          ..write('interpretation: $interpretation, ')
          ..write('detailedScores: $detailedScores, ')
          ..write('patientId: $patientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      scaleType,
      scaleVersion,
      caseDescription,
      totalScore,
      interpretation,
      detailedScores,
      patientId,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvaluationRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.scaleType == this.scaleType &&
          other.scaleVersion == this.scaleVersion &&
          other.caseDescription == this.caseDescription &&
          other.totalScore == this.totalScore &&
          other.interpretation == this.interpretation &&
          other.detailedScores == this.detailedScores &&
          other.patientId == this.patientId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EvaluationsCompanion extends UpdateCompanion<EvaluationRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> scaleType;
  final Value<int> scaleVersion;
  final Value<String> caseDescription;
  final Value<int> totalScore;
  final Value<String> interpretation;
  final Value<String> detailedScores;
  final Value<String?> patientId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EvaluationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.scaleType = const Value.absent(),
    this.scaleVersion = const Value.absent(),
    this.caseDescription = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.interpretation = const Value.absent(),
    this.detailedScores = const Value.absent(),
    this.patientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvaluationsCompanion.insert({
    required String id,
    required String userId,
    required String scaleType,
    required int scaleVersion,
    required String caseDescription,
    required int totalScore,
    required String interpretation,
    required String detailedScores,
    this.patientId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        scaleType = Value(scaleType),
        scaleVersion = Value(scaleVersion),
        caseDescription = Value(caseDescription),
        totalScore = Value(totalScore),
        interpretation = Value(interpretation),
        detailedScores = Value(detailedScores),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<EvaluationRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? scaleType,
    Expression<int>? scaleVersion,
    Expression<String>? caseDescription,
    Expression<int>? totalScore,
    Expression<String>? interpretation,
    Expression<String>? detailedScores,
    Expression<String>? patientId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (scaleType != null) 'scale_type': scaleType,
      if (scaleVersion != null) 'scale_version': scaleVersion,
      if (caseDescription != null) 'case_description': caseDescription,
      if (totalScore != null) 'total_score': totalScore,
      if (interpretation != null) 'interpretation': interpretation,
      if (detailedScores != null) 'detailed_scores': detailedScores,
      if (patientId != null) 'patient_id': patientId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvaluationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? scaleType,
      Value<int>? scaleVersion,
      Value<String>? caseDescription,
      Value<int>? totalScore,
      Value<String>? interpretation,
      Value<String>? detailedScores,
      Value<String?>? patientId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return EvaluationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scaleType: scaleType ?? this.scaleType,
      scaleVersion: scaleVersion ?? this.scaleVersion,
      caseDescription: caseDescription ?? this.caseDescription,
      totalScore: totalScore ?? this.totalScore,
      interpretation: interpretation ?? this.interpretation,
      detailedScores: detailedScores ?? this.detailedScores,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scaleType.present) {
      map['scale_type'] = Variable<String>(scaleType.value);
    }
    if (scaleVersion.present) {
      map['scale_version'] = Variable<int>(scaleVersion.value);
    }
    if (caseDescription.present) {
      map['case_description'] = Variable<String>(caseDescription.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<int>(totalScore.value);
    }
    if (interpretation.present) {
      map['interpretation'] = Variable<String>(interpretation.value);
    }
    if (detailedScores.present) {
      map['detailed_scores'] = Variable<String>(detailedScores.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvaluationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scaleType: $scaleType, ')
          ..write('scaleVersion: $scaleVersion, ')
          ..write('caseDescription: $caseDescription, ')
          ..write('totalScore: $totalScore, ')
          ..write('interpretation: $interpretation, ')
          ..write('detailedScores: $detailedScores, ')
          ..write('patientId: $patientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientsTable extends Patients
    with TableInfo<$PatientsTable, PatientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, alias, notes, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(Insertable<PatientRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
          _aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class PatientRow extends DataClass implements Insertable<PatientRow> {
  final String id;
  final String userId;
  final String alias;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PatientRow(
      {required this.id,
      required this.userId,
      required this.alias,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['alias'] = Variable<String>(alias);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      userId: Value(userId),
      alias: Value(alias),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PatientRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      alias: serializer.fromJson<String>(json['alias']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'alias': serializer.toJson<String>(alias),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PatientRow copyWith(
          {String? id,
          String? userId,
          String? alias,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PatientRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        alias: alias ?? this.alias,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PatientRow copyWithCompanion(PatientsCompanion data) {
    return PatientRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      alias: data.alias.present ? data.alias.value : this.alias,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('alias: $alias, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, alias, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.alias == this.alias &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientsCompanion extends UpdateCompanion<PatientRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> alias;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.alias = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String userId,
    required String alias,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        alias = Value(alias),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PatientRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? alias,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (alias != null) 'alias': alias,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? alias,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PatientsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alias: alias ?? this.alias,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('alias: $alias, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EvaluationsTable evaluations = $EvaluationsTable(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final EvaluationsDao evaluationsDao =
      EvaluationsDao(this as AppDatabase);
  late final PatientsDao patientsDao = PatientsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [evaluations, patients];
}

typedef $$EvaluationsTableCreateCompanionBuilder = EvaluationsCompanion
    Function({
  required String id,
  required String userId,
  required String scaleType,
  required int scaleVersion,
  required String caseDescription,
  required int totalScore,
  required String interpretation,
  required String detailedScores,
  Value<String?> patientId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$EvaluationsTableUpdateCompanionBuilder = EvaluationsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> scaleType,
  Value<int> scaleVersion,
  Value<String> caseDescription,
  Value<int> totalScore,
  Value<String> interpretation,
  Value<String> detailedScores,
  Value<String?> patientId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$EvaluationsTableFilterComposer
    extends Composer<_$AppDatabase, $EvaluationsTable> {
  $$EvaluationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scaleType => $composableBuilder(
      column: $table.scaleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scaleVersion => $composableBuilder(
      column: $table.scaleVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseDescription => $composableBuilder(
      column: $table.caseDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalScore => $composableBuilder(
      column: $table.totalScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get interpretation => $composableBuilder(
      column: $table.interpretation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailedScores => $composableBuilder(
      column: $table.detailedScores,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$EvaluationsTableOrderingComposer
    extends Composer<_$AppDatabase, $EvaluationsTable> {
  $$EvaluationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scaleType => $composableBuilder(
      column: $table.scaleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scaleVersion => $composableBuilder(
      column: $table.scaleVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseDescription => $composableBuilder(
      column: $table.caseDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalScore => $composableBuilder(
      column: $table.totalScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get interpretation => $composableBuilder(
      column: $table.interpretation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailedScores => $composableBuilder(
      column: $table.detailedScores,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$EvaluationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvaluationsTable> {
  $$EvaluationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get scaleType =>
      $composableBuilder(column: $table.scaleType, builder: (column) => column);

  GeneratedColumn<int> get scaleVersion => $composableBuilder(
      column: $table.scaleVersion, builder: (column) => column);

  GeneratedColumn<String> get caseDescription => $composableBuilder(
      column: $table.caseDescription, builder: (column) => column);

  GeneratedColumn<int> get totalScore => $composableBuilder(
      column: $table.totalScore, builder: (column) => column);

  GeneratedColumn<String> get interpretation => $composableBuilder(
      column: $table.interpretation, builder: (column) => column);

  GeneratedColumn<String> get detailedScores => $composableBuilder(
      column: $table.detailedScores, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EvaluationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EvaluationsTable,
    EvaluationRow,
    $$EvaluationsTableFilterComposer,
    $$EvaluationsTableOrderingComposer,
    $$EvaluationsTableAnnotationComposer,
    $$EvaluationsTableCreateCompanionBuilder,
    $$EvaluationsTableUpdateCompanionBuilder,
    (
      EvaluationRow,
      BaseReferences<_$AppDatabase, $EvaluationsTable, EvaluationRow>
    ),
    EvaluationRow,
    PrefetchHooks Function()> {
  $$EvaluationsTableTableManager(_$AppDatabase db, $EvaluationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvaluationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvaluationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvaluationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> scaleType = const Value.absent(),
            Value<int> scaleVersion = const Value.absent(),
            Value<String> caseDescription = const Value.absent(),
            Value<int> totalScore = const Value.absent(),
            Value<String> interpretation = const Value.absent(),
            Value<String> detailedScores = const Value.absent(),
            Value<String?> patientId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EvaluationsCompanion(
            id: id,
            userId: userId,
            scaleType: scaleType,
            scaleVersion: scaleVersion,
            caseDescription: caseDescription,
            totalScore: totalScore,
            interpretation: interpretation,
            detailedScores: detailedScores,
            patientId: patientId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String scaleType,
            required int scaleVersion,
            required String caseDescription,
            required int totalScore,
            required String interpretation,
            required String detailedScores,
            Value<String?> patientId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EvaluationsCompanion.insert(
            id: id,
            userId: userId,
            scaleType: scaleType,
            scaleVersion: scaleVersion,
            caseDescription: caseDescription,
            totalScore: totalScore,
            interpretation: interpretation,
            detailedScores: detailedScores,
            patientId: patientId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EvaluationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EvaluationsTable,
    EvaluationRow,
    $$EvaluationsTableFilterComposer,
    $$EvaluationsTableOrderingComposer,
    $$EvaluationsTableAnnotationComposer,
    $$EvaluationsTableCreateCompanionBuilder,
    $$EvaluationsTableUpdateCompanionBuilder,
    (
      EvaluationRow,
      BaseReferences<_$AppDatabase, $EvaluationsTable, EvaluationRow>
    ),
    EvaluationRow,
    PrefetchHooks Function()>;
typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required String userId,
  required String alias,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> alias,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PatientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatientsTable,
    PatientRow,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (PatientRow, BaseReferences<_$AppDatabase, $PatientsTable, PatientRow>),
    PatientRow,
    PrefetchHooks Function()> {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> alias = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion(
            id: id,
            userId: userId,
            alias: alias,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String alias,
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion.insert(
            id: id,
            userId: userId,
            alias: alias,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatientsTable,
    PatientRow,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (PatientRow, BaseReferences<_$AppDatabase, $PatientsTable, PatientRow>),
    PatientRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EvaluationsTableTableManager get evaluations =>
      $$EvaluationsTableTableManager(_db, _db.evaluations);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
}
