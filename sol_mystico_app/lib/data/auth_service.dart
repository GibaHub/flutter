import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<String?> login(String email, String password) async {
    try {
      print('Tentando login em: ${_dio.options.baseUrl}/auth/login');
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['access_token'];
        await _storage.write(key: 'jwt_token', value: token);
        return token;
      }
      return null;
    } on DioException catch (e) {
      print('Erro Dio: ${e.message} - ${e.response?.statusCode}');
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      }
      throw Exception(
        'Erro de conexão: ${e.message} (URL: ${_dio.options.baseUrl})',
      );
    } catch (e) {
      print('Erro geral: $e');
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}
