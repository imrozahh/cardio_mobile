import 'package:equatable/equatable.dart';

abstract class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPredictionHistory extends PredictionEvent {
  final int page;

  const LoadPredictionHistory({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class ClearPredictionState extends PredictionEvent {}

class Predict extends PredictionEvent {
  final Map<String, dynamic> data;

  const Predict(this.data);

  @override
  List<Object?> get props => [data];
}
