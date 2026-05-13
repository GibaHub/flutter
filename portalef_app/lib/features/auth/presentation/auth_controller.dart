import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_repository.dart';
import '../domain/user.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.readToken();
    final userJson = await storage.readUserJson();

    if (token == null || token.isEmpty || userJson == null || userJson.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(userJson);
    if (decoded is! Map<String, Object?>) return null;

    final user = User.fromJson(decoded);
    return AuthSession(user: user, token: token);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading<AuthSession?>();
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(secureStorageProvider);

    state = await AsyncValue.guard(() async {
      final result = await repo.login(email: email, password: password);
      await storage.writeToken(result.token);
      await storage.writeUserJson(result.userJson);
      return AuthSession(user: result.user, token: result.token);
    });
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearSession();
    state = const AsyncData<AuthSession?>(null);
  }
}

class AuthSession {
  const AuthSession({required this.user, required this.token});

  final User user;
  final String token;
}

