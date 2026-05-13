import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';

class ApiClient {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.post(
      url, 
      headers: headers, 
      body: body != null ? jsonEncode(body) : null
    );
  }
  
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.put(
      url, 
      headers: headers, 
      body: body != null ? jsonEncode(body) : null
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    return await http.delete(url, headers: headers);
  }
}
