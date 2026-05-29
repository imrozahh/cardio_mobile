import 'package:dartz/dartz.dart';

import '../../domain/repositories/prediction_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/prediction_model.dart';
import '../../domain/entities/prediction_entity.dart';

class PredictionRepositoryImpl implements PredictionRepository {
  final ApiClient apiClient;

  PredictionRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, PredictionEntity>> predict(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.post(ApiEndpoints.predict, data: data);

      final responseData = response.data;

      final Map<String, dynamic> predictionJson =
          responseData is Map<String, dynamic> &&
              responseData['prediction'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(responseData['prediction'])
          : responseData is Map<String, dynamic> &&
                responseData['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(responseData['data'])
          : Map<String, dynamic>.from(responseData);

      predictionJson['input_data'] ??= data;
      predictionJson['user_id'] ??= '';
      predictionJson['created_at'] ??= DateTime.now().toIso8601String();

      final model = PredictionModel.fromJson(predictionJson);

      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PredictionEntity>>> getHistory({
    int page = 1,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.predictionHistory,
        queryParams: {'page': page},
      );

      final responseData = response.data;

      List<dynamic> list = [];

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];

        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          list = data['data'] as List;
        }
      } else if (responseData is List) {
        list = responseData;
      }

      final items = list
          .whereType<Map>()
          .map((e) => PredictionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PredictionEntity>> getDetail(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.predictionDetail(id));

      final responseData = response.data;

      final Map<String, dynamic> predictionJson =
          responseData is Map<String, dynamic> &&
              responseData['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(responseData['data'])
          : Map<String, dynamic>.from(responseData);

      final model = PredictionModel.fromJson(predictionJson);

      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
