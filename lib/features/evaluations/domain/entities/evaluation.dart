class Evaluation {
  const Evaluation({
    required this.id,
    required this.userId,
    required this.scaleType,
    required this.scaleVersion,
    required this.caseDescription,
    required this.totalScore,
    required this.interpretation,
    required this.detailedScores,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String scaleType;
  final int scaleVersion;
  final String caseDescription;
  final int totalScore;
  final String interpretation;
  final Map<String, dynamic> detailedScores;
  final DateTime createdAt;
  final DateTime updatedAt;
}
