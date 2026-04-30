import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage storage;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.storage,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final userModel = UserModel.fromJson(response.data['user']);

      await storage.write(key: AppConstants.tokenKey, value: token);
      await storage.write(key: AppConstants.userKey, value: jsonEncode(userModel.toJson()));

      return Right(userModel);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Email atau password salah.'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await apiClient.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final token = response.data['access_token'];
      final userModel = UserModel.fromJson(response.data['user']);

      await storage.write(key: AppConstants.tokenKey, value: token);
      await storage.write(key: AppConstants.userKey, value: jsonEncode(userModel.toJson()));

      return Right(userModel);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
      await storage.deleteAll();
      return const Right(null);
    } catch (e) {
      // Even if API fails, we clear local storage
      await storage.deleteAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userData = await storage.read(key: AppConstants.userKey);
      if (userData != null) {
        return Right(UserModel.fromJson(jsonDecode(userData)));
      }
      return const Left(CacheFailure());
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: AppConstants.tokenKey);
    return token != null;
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await apiClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({required String email, required String otp}) async {
    try {
      await apiClient.post(ApiEndpoints.verifyOtp, data: {'email': email, 'otp': otp});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await apiClient.post(ApiEndpoints.resetPassword, data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
