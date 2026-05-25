import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/prediction_repository.dart';
import 'prediction_event.dart';
import 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final PredictionRepository predictionRepository;

  PredictionBloc({required this.predictionRepository})
    : super(PredictionInitial()) {
    on<LoadPredictionHistory>(_onLoadHistory);
    on<Predict>(_onPredict);
    on<ClearPredictionState>((event, emit) => emit(PredictionInitial()));
  }

  Future<void> _onLoadHistory(
    LoadPredictionHistory event,
    Emitter<PredictionState> emit,
  ) async {
    emit(PredictionLoading());
    try {
      final result = await predictionRepository.getHistory(page: event.page);
      result.fold(
        (l) => emit(PredictionFailure(l.toString())),
        (r) => emit(PredictionLoaded(r)),
      );
    } catch (e) {
      emit(PredictionFailure(e.toString()));
    }
  }

  Future<void> _onPredict(Predict event, Emitter<PredictionState> emit) async {
    emit(PredictionLoading());
    try {
      final result = await predictionRepository.predict(event.data);
      result.fold(
        (l) => emit(PredictionFailure(l.toString())),
        (r) => emit(PredictionSuccess(r)),
      );
    } catch (e) {
      emit(PredictionFailure(e.toString()));
    }
  }
}
