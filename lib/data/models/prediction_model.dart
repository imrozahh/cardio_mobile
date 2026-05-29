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
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',

      inputData: json['input_data'] is Map
          ? Map<String, dynamic>.from(json['input_data'])
          : <String, dynamic>{},

      // Untuk POST /predict: risk_score
      // Untuk GET /predictions: result_score
      riskScore:
          (json['risk_score'] as num?)?.toDouble() ??
          (json['result_score'] as num?)?.toDouble() ??
          0.0,

      // Untuk POST /predict: risk_level
      // Untuk GET /predictions: result_level
      riskLevel:
          json['risk_level']?.toString() ??
          json['result_level']?.toString() ??
          '',

      recommendation:
          json['recommendation']?.toString() ??
          json['recommendations']?.toString() ??
          '',

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
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
