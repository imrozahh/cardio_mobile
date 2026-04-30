/// Prediction entity - mirrors the Prediction model from Laravel backend
class PredictionEntity {
  final String id;
  final String userId;
  final Map<String, dynamic> inputData;
  final double riskScore;
  final String riskLevel; // 'low', 'medium', 'high'
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

  bool get isHighRisk => riskLevel == 'high';
  bool get isMediumRisk => riskLevel == 'medium';
  bool get isLowRisk => riskLevel == 'low';

  String get riskPercentage => '${(riskScore * 100).toStringAsFixed(1)}%';
}
