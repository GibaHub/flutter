import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ranking_vendas_model.dart';
import '../models/inadimplencia_model.dart';

class ApiService {
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
    throw Exception('Failed after $retries attempts');
  }

  final String _tokenUrl = '$_baseUrl/api/oauth2/v1/token';
  final String _vendasUrl = '$_baseUrl/appcometa/vendas/rankingvendas';

  Future<String> _obterToken() async {
    final response = await _retryRequest(() => http.post(
          Uri.parse(_tokenUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'password',
            'username': 'cometa.service',
            'password': '103020',
          },
        ));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Falha ao obter token: ${response.statusCode}');
    }
  }

  Future<List<RankingVendasModel>> fetchRankingVendas() async {
    final token = await _obterToken();

    final response = await _retryRequest(() => http.get(Uri.parse(_vendasUrl),
        headers: {'Authorization': 'Bearer $token'}));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => RankingVendasModel.fromJson(item)).toList();
    } else {
      throw Exception(
          'Erro ao buscar ranking de vendas: ${response.statusCode}');
    }
  }

  Future<dynamic> getWithAuth(String endpoint,
      {Map<String, dynamic>? body}) async {
    final token = await _obterToken();
    final url = '$_baseUrl$endpoint';
    final response = await _retryRequest(() =>
        http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'}));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar $endpoint: ${response.statusCode}');
    }
  }

  Future<dynamic> puttWithAuth(
      String endpoint, Map<String, dynamic> body) async {
    final token = await _obterToken();
    final url = Uri.parse('$_baseUrl$endpoint');

    if (kDebugMode) {
      debugPrint('ApiService: Enviando PUT para $url');
    }

    final response = await _retryRequest(() => http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        ));

    if (kDebugMode) {
      debugPrint('ApiService: Resposta Status: ${response.statusCode}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Erro ao enviar dados para $endpoint: ${response.statusCode} - ${response.body}');
    }
  }

  Future<dynamic> postWithAuth(
      String endpoint, Map<String, dynamic> body) async {
    final token = await _obterToken();
    final uri = Uri.parse('$_baseUrl$endpoint');

    if (kDebugMode) {
      debugPrint('ApiService: Enviando POST para $uri');
    }

    final response = await _retryRequest(() => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        ));

    if (kDebugMode) {
      debugPrint('ApiService: Resposta Status: ${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return null;
      return json.decode(response.body);
    }

    throw Exception(
        'Erro ao enviar dados para $endpoint: ${response.statusCode} - ${response.body}');
  }

  Future<http.Response> postJsonWithAuthUrl(
      String url, Map<String, dynamic> body) async {
    final token = await _obterToken();
    final uri = Uri.parse(url);

    if (kDebugMode) {
      debugPrint('ApiService: Enviando POST para $uri');
    }

    final response = await _retryRequest(() => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        ));

    if (kDebugMode) {
      debugPrint('ApiService: Resposta Status: ${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    throw Exception(
        'Erro ao enviar dados para $uri: ${response.statusCode} - ${response.body}');
  }

  // Método para buscar filiais com vendas online
  Future<dynamic> getVendasOnlineFiliais() async {
    return await getWithAuth('/appcometa/vendas/online/filiais');
  }

  // Método para buscar vendas online por filial
  Future<dynamic> getVendasOnlinePorFilial(String filial) async {
    return await getWithAuth('/appcometa/vendas/online?filial=$filial');
  }

  // Método para buscar títulos a pagar e receber
  Future<dynamic> getTitulosPagarReceber() async {
    return await getWithAuth('/appcometa/vendas/titulospagarereceber');
  }

  // Método para buscar clientes inadimplentes
  Future<List<InadimplenciaModel>> getClientesInadimplentes(
      Map<String, String> parametros) async {
    final queryParams =
        parametros.entries.map((e) => '${e.key}=${e.value}').join('&');

    final endpoint = '/appcometa/clientes/clientesinadimplentes?$queryParams';
    final data = await getWithAuth(endpoint);

    if (data is List) {
      return data.map((item) => InadimplenciaModel.fromJson(item)).toList();
    } else {
      throw Exception('Formato de resposta inválido para inadimplência');
    }
  }
}
