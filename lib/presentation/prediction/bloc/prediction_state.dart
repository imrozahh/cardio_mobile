import 'package:equatable/equatable.dart';
import '../../../domain/entities/prediction_entity.dart';

abstract class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object?> get props => [];
}

class PredictionInitial extends PredictionState {}

class PredictionLoading extends PredictionState {}

class PredictionLoaded extends PredictionState {
  final List<PredictionEntity> items;

  const PredictionLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class PredictionFailure extends PredictionState {
  final String message;

  const PredictionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PredictionSuccess extends PredictionState {
  final PredictionEntity prediction;

  const PredictionSuccess(this.prediction);

  @override
  List<Object?> get props => [prediction];
}
