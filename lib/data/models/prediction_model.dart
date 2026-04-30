import '../../domain/entities/prediction_entity.dart';

class PredictionModel extends PredictionEntity {
  const PredictionModel({
    required super.id,
    required super.userId,
    required super.inputData,
    required super.riskScore,
    required super.riskLevel,
    required super.recommendation,
    required super.createdAt,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      inputData: json['input_data'] as Map<String, dynamic>,
      riskScore: (json['risk_score'] as num).toDouble(),
      riskLevel: json['risk_level'],
      recommendation: json['recommendation'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'input_data': inputData,
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'recommendation': recommendation,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
