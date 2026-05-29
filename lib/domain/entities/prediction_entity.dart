/// Prediction entity - mirrors the Prediction model from Laravel backend
class PredictionEntity {
  final String id;
  final String userId;
  final Map<String, dynamic> inputData;
  final double riskScore;
  final String riskLevel; // 'RENDAH', 'SEDANG', 'TINGGI'
  final String recommendation;
  final DateTime createdAt;

  const PredictionEntity({
    required this.id,
    required this.userId,
    required this.inputData,
    required this.riskScore,
    required this.riskLevel,
    required this.recommendation,
    required this.createdAt,
  });

  String get normalizedRiskLevel => riskLevel.toUpperCase();

  bool get isHighRisk =>
      normalizedRiskLevel == 'TINGGI' || normalizedRiskLevel == 'HIGH';

  bool get isMediumRisk =>
      normalizedRiskLevel == 'SEDANG' || normalizedRiskLevel == 'MEDIUM';

  bool get isLowRisk =>
      normalizedRiskLevel == 'RENDAH' || normalizedRiskLevel == 'LOW';

  String get riskPercentage => '${riskScore.toStringAsFixed(1)}%';
}
