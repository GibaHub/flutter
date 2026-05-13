import '../core/app_modules.dart';

class UserModel {
  final String id;
  final String nome;
  final String apelido;
  final String email;
  final String departamento;
  final String role;
  final bool ativo;
  final List<String> permissoesApps;
  final List<String> permissoesLojas;

  const UserModel({
    required this.id,
    required this.nome,
    required this.apelido,
    required this.email,
    required this.departamento,
    required this.role,
    required this.ativo,
    required this.permissoesApps,
    required this.permissoesLojas,
  });

  UserModel copyWith({
    String? id,
    String? nome,
    String? apelido,
    String? email,
    String? departamento,
    String? role,
    bool? ativo,
    List<String>? permissoesApps,
    List<String>? permissoesLojas,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      apelido: apelido ?? this.apelido,
      email: email ?? this.email,
      departamento: departamento ?? this.departamento,
      role: role ?? this.role,
      ativo: ativo ?? this.ativo,
      permissoesApps: permissoesApps ?? List<String>.from(this.permissoesApps),
      permissoesLojas:
          permissoesLojas ?? List<String>.from(this.permissoesLojas),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawPermApps = json['permissoesApps'];
    final rawPermLojas = json['permissoesLojas'];

    final parsedPermApps = _parseStringList(rawPermApps);
    final parsedPermLojas = _parseStringList(rawPermLojas);

    final inferredApps = parsedPermApps.isNotEmpty
        ? parsedPermApps
        : _inferPermissoesApps(json);
    final inferredLojas = parsedPermLojas.isNotEmpty
        ? parsedPermLojas
        : _inferPermissoesLojas(json);

    return UserModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      apelido: (json['apelido'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      departamento: (json['departamento'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      ativo: _parseBool(json['ativo'] ?? json['active'] ?? true),
      permissoesApps: inferredApps,
      permissoesLojas: inferredLojas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'departamento': departamento,
      'role': role,
      'ativo': ativo,
      'permissoesApps': permissoesApps,
      'permissoesLojas': permissoesLojas,
    };
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    final v = value?.toString().trim().toUpperCase();
    if (v == null) return false;
    return v == 'S' || v == '1' || v == 'TRUE' || v == 'T';
  }

  static bool _isTruthy(dynamic value) => _parseBool(value);

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    final str = value.toString().trim();
    if (str.isEmpty) return <String>[];
    if (str.contains(',')) {
      return str
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return <String>[str];
  }

  static List<String> _inferPermissoesApps(Map<String, dynamic> json) {
    final inferred = <String>[];

    for (final module in AppModule.values) {
      if (_isTruthy(json[module.apiKey])) {
        inferred.add(module.key);
      }
    }

    if (inferred.isEmpty) {
      if (_isTruthy(json['caddastrocli'])) inferred.add(AppModule.clientes.key);
      if (_isTruthy(json['vertitulos'])) inferred.add(AppModule.titulos.key);
      if (_isTruthy(json['alteralimite'])) inferred.add(AppModule.limites.key);
      if (_isTruthy(json['resumovenda'])) inferred.add(AppModule.vendas.key);
      if (_isTruthy(json['indenizacao'])) inferred.add(AppModule.indenizacoes.key);
      if (_isTruthy(json['despesas'])) inferred.add(AppModule.despesas.key);
      if (_isTruthy(json['inadimplencia'])) {
        inferred.add(AppModule.inadimplencia.key);
      }
      if (_isTruthy(json['rankingvendedor'])) {
        inferred.add(AppModule.vendedores.key);
      }
      if (_isTruthy(json['cadastrausers'])) inferred.add(AppModule.usuarios.key);
      if (_isTruthy(json['cancelabaixa'])) inferred.add(AppModule.baixas.key);
    }

    return inferred.toSet().toList();
  }

  static List<String> _inferPermissoesLojas(Map<String, dynamic> json) {
    final inferred = <String>[];

    for (var i = 1; i <= 32; i++) {
      final loja = i.toString().padLeft(2, '0');
      final key = 'lj$loja';
      final oldKey = 'loja$loja';
      if (_isTruthy(json[key]) || _isTruthy(json[oldKey])) {
        inferred.add(loja);
      }
    }

    return inferred.toSet().toList();
  }
}
