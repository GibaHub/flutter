import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../core/app_modules.dart';
import 'auth_service.dart';

class UsersService {
  final AuthService _authService = AuthService();

  static const String _baseUrl = 'https://appcometa.fortiddns.com';
  static const String _consultUrl =
      '$_baseUrl/appcometa/users/consultacometausers';
  static const String _updateUrl = '$_baseUrl/appcometa/users/updatecometusers';

  static const Map<AppModule, String> _updateKeys = {
    AppModule.clientes: 'caddastrocli',
    AppModule.titulos: 'vertitulos',
    AppModule.limites: 'alteralimite',
    AppModule.vendas: 'resumovenda',
    AppModule.indenizacoes: 'indenizacao',
    AppModule.despesas: 'despesas',
    AppModule.inadimplencia: 'inadimplencia',
    AppModule.vendedores: 'rankingvendedor',
    AppModule.usuarios: 'cadastrausers',
    AppModule.baixas: 'cancelabaixa',
  };

  Future<List<UserModel>> fetchUsers({String query = ''}) async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse(_consultUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar usuários: ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    List<UserModel> users = <UserModel>[];

    if (decoded is Map<String, dynamic>) {
      final list = decoded['Lista_Usuarios'];
      if (list is List) {
        users = list
            .whereType<Map>()
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } else if (decoded is List) {
      users = decoded
          .whereType<Map>()
          .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final q = query.trim().toLowerCase();
    if (q.isEmpty) return users;

    return users.where((u) {
      return u.nome.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> upsertUser(UserModel user, {required String senha}) async {
    final token = await _authService.getToken();

    final body = _buildUpdateBody(user, senha: senha);

    final response = await http.put(
      Uri.parse(_updateUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Erro ao salvar usuário: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Map<String, dynamic> _buildUpdateBody(UserModel user,
      {required String senha}) {
    final apps = user.permissoesApps.map((e) => e.toLowerCase()).toSet();
    final lojas = user.permissoesLojas.map((e) => e.padLeft(2, '0')).toSet();

    final payload = <String, dynamic>{
      'nome': user.nome,
      'apelido': user.nome,
      'email': user.email,
      'telefone': '',
      'senha': senha,
      'validsenha': senha,
      'depto': user.departamento,
    };

    for (final entry in _updateKeys.entries) {
      payload[entry.value] = apps.contains(entry.key.key) ? 'S' : 'N';
    }

    // Lojas (API de update usa lojaXX)
    for (var i = 1; i <= 32; i++) {
      final loja = i.toString().padLeft(2, '0');
      payload['loja$loja'] = lojas.contains(loja) ? 'S' : 'N';
    }

    return payload;
  }
}
