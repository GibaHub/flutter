import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

class AuthService with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      _user = data['user'];
      
      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: 'user_data', value: jsonEncode(_user));
      
      _isAuthenticated = true;
      notifyListeners();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no login');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'jwt_token');
    final userData = await _storage.read(key: 'user_data');
    
    if (token != null && userData != null) {
      _isAuthenticated = true;
      _user = jsonDecode(userData);
      notifyListeners();
    }
  }
}
