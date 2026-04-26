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
      );

  /// Only includes columns managed by the app — Supabase generates id/timestamps.
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'scale_type': scaleType,
        'scale_version': scaleVersion,
        'case_description': caseDescription,
        'total_score': totalScore,
        'interpretation': interpretation,
        'detailed_scores': detailedScores,
      };
}
