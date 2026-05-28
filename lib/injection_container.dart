import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';

import 'data/datasources/chat_remote_data_source.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'presentation/chat/bloc/chat_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── External ─────────────────────────────────────────────────────────────
  const storage = FlutterSecureStorage();
  sl.registerLazySingleton(() => storage);

  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient(sl()));

  // ── Data Sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiClient: sl()),
  );

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(apiClient: sl(), storage: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => ChatBloc(repository: sl()));
}
