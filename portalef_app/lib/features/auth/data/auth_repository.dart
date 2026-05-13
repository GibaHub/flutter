import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {'email': email, 'password': password},
    );

    final raw = response.data ?? <String, dynamic>{};
    final data = Map<String, Object?>.from(raw);
    final token = (data['token'] as String?) ?? '';

    if (token.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Token ausente no response',
        type: DioExceptionType.badResponse,
      );
    }

    final user = User.fromJson(data);
    return LoginResult(
      user: user,
      token: token,
      userJson: jsonEncode(user.toJson()),
    );
  }
}

class LoginResult {
  const LoginResult({
    required this.user,
    required this.token,
    required this.userJson,
  });

  final User user;
  final String token;
  final String userJson;
}
