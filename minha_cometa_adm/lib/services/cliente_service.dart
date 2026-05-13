import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';

class ClienteService {
  static Future<http.Response> _retryRequest(
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

  static const String baseUrl = 'https://appcometa.fortiddns.com/appcometa';

  static Future<ClienteModel> getCliente(String codigo) async {
    final url = Uri.parse('$baseUrl/get/ClientDataSearch?codigo=$codigo');
    final response =
        await _retryRequest(() => _retryRequest(() => http.get(url)));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ClienteModel.fromJson(data);
    } else {
      throw Exception('Erro ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  static Future<bool> alterarLimite(String codigo, double novoLimite) async {
    final url = Uri.parse('$baseUrl/client/changelimit');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'codigo': codigo, 'limite': novoLimite}),
    );
    return response.statusCode == 200;
  }
}
