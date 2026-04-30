import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Features ─────────────────────────────────────────────────────────────
  
  // BLoCs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiClient: sl(),
      storage: sl(),
    ),
  );

  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient(sl()));

  // ── External ─────────────────────────────────────────────────────────────
  const storage = FlutterSecureStorage();
  sl.registerLazySingleton(() => storage);
}
