import '../../domain/entities/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.userId,
    required super.alias,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PatientModel.fromEntity(Patient p) => PatientModel(
        id: p.id,
        userId: p.userId,
        alias: p.alias,
        notes: p.notes,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      );

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        alias: json['alias'] as String,
        notes: (json['notes'] as String?) ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  /// Only includes columns managed by the app — Supabase generates id/timestamps.
  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'alias': alias,
        'notes': notes,
      };

  Map<String, dynamic> toUpdateJson() => {
        'alias': alias,
        'notes': notes,
      };
}
