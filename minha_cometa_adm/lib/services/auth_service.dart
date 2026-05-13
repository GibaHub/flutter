import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class AuthService {
  static const String _baseUrl = 'https://appcometa.fortiddns.com';

  Future<http.Response> _retryRequest(
      Future<http.Response> Function() requestFunc,
      {int retries = 3,
      Duration delay = const Duration(seconds: 1)}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        final response = await requestFunc();
        if (response.statusCode < 500) {
          return response;
        }
      } catch (_) {
        if (attempt == retries - 1) rethrow;
      }
      attempt++;
      await Future.delayed(delay);
    }
    throw Exception('Failed after \$retries attempts');
  }

  final storage = const FlutterSecureStorage();
  final _tokenUrl = '$_baseUrl/api/oauth2/v1/token';
  final _validateUrl = '$_baseUrl/appcometa/users/validatecometusers';

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('access_token');

    if (savedToken != null && savedToken.trim().isNotEmpty) return savedToken;

    final response = await _retryRequest(() => _retryRequest(() => http.post(
          Uri.parse(_tokenUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'password',
            'username': 'cometa.service', // ✅ CORRETO
            'password': '103020', // ✅ CORRETO
          },
        )));

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      await prefs.setString('access_token', token);
      return token;
    } else {
      throw Exception('Falha ao obter token');
    }
  }

  Future<bool> loginWithCredentials(
      BuildContext context, String username, String password) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = await getToken();

    try {
      var validateResponse =
          await _retryRequest(() => _retryRequest(() => http.post(
                Uri.parse(_validateUrl),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: json.encode({'email': username, 'password': password}),
              )));

      if (validateResponse.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        final refreshedToken = await getToken();

        validateResponse =
            await _retryRequest(() => _retryRequest(() => http.post(
                  Uri.parse(_validateUrl),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $refreshedToken',
                  },
                  body: json.encode({'email': username, 'password': password}),
                )));
      }

      if (validateResponse.statusCode == 200) {
        final userData = json.decode(validateResponse.body);
        userProvider.setUserInfoFromJson(userData);
        await authProvider
            .setUserFromJson((userData as Map).cast<String, dynamic>());

        // Salvar dados do usuário no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final apelido = (userData['apelido'] ?? '').toString().trim();
        await prefs.setString('user_name',
            apelido.isNotEmpty ? apelido : (userData['nome'] ?? ''));
        await prefs.setString('user_email', userData['email'] ?? '');

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> obterToken() async {
    return getToken();
  }

  Future<Map<String, String?>> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final mail = prefs.getString('user_email');
    return {
      'name': name,
      'email': mail,
    };
  }

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;
      if (!isAvailable) return false;

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor, autentique-se para continuar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      debugPrint('Erro na biometria: $e');
      return false;
    }
  }

  Future<bool> checkAndUseBiometrics() async {
    final token = await storage.read(key: 'token');
    if (token != null) {
      final authenticated = await authenticateWithBiometrics();
      return authenticated;
    }
    return false;
  }
}
