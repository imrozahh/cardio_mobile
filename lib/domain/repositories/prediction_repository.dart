import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/prediction_entity.dart';

abstract class PredictionRepository {
  Future<Either<Failure, PredictionEntity>> predict(Map<String, dynamic> data);
  Future<Either<Failure, List<PredictionEntity>>> getHistory({int page = 1});
  Future<Either<Failure, PredictionEntity>> getDetail(String id);
}
