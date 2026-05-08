import '../../domain/entities/evaluation.dart';

class EvaluationModel extends Evaluation {
  const EvaluationModel({
    required super.id,
    required super.userId,
    required super.scaleType,
    required super.scaleVersion,
    required super.caseDescription,
    required super.totalScore,
    required super.interpretation,
    required super.detailedScores,
    required super.createdAt,
    required super.updatedAt,
    super.patientId,
  });

  factory EvaluationModel.fromEntity(Evaluation e) => EvaluationModel(
    id: e.id,
    userId: e.userId,
    scaleType: e.scaleType,
    scaleVersion: e.scaleVersion,
    caseDescription: e.caseDescription,
    totalScore: e.totalScore,
    interpretation: e.interpretation,
    detailedScores: e.detailedScores,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    patientId: e.patientId,
  );

  factory EvaluationModel.fromJson(Map<String, dynamic> json) =>
      EvaluationModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        scaleType: json['scale_type'] as String,
        scaleVersion: json['scale_version'] as int,
        caseDescription: (json['case_description'] as String?) ?? '',
        totalScore: json['total_score'] as int,
        interpretation: json['interpretation'] as String,
        detailedScores:
            (json['detailed_scores'] as Map<String, dynamic>?) ?? {},
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        patientId: json['patient_id'] as String?,
      );

  /// Only includes columns managed by the app — Supabase generates id/timestamps.
  /// patient_id is included even when null (Supabase accepts null FK).
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'scale_type': scaleType,
    'scale_version': scaleVersion,
    'case_description': caseDescription,
    'total_score': totalScore,
    'interpretation': interpretation,
    'detailed_scores': detailedScores,
    'patient_id': patientId,
  };
}
