import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/prediction_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/prediction_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/prediction/bloc/prediction_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── External ─────────────────────────────────────────────────────────────
  const storage = FlutterSecureStorage();
  sl.registerLazySingleton(() => storage);

  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient(sl()));

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(apiClient: sl(), storage: sl()),
  );
  sl.registerLazySingleton<PredictionRepository>(
    () => PredictionRepositoryImpl(apiClient: sl()),
  );

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => PredictionBloc(predictionRepository: sl()));
}
