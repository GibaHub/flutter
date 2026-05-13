import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/app_modules.dart';

class AuthProvider extends ChangeNotifier {
  static const _prefsUserJsonKey = 'cometa_user_json';

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Future<void> loadFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsUserJsonKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = json.decode(raw);
        if (decoded is Map<String, dynamic>) {
          _currentUser = _buildUserFromBackend(decoded);
        }
      }
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setUserFromJson(Map<String, dynamic> jsonMap) async {
    _currentUser = _buildUserFromBackend(jsonMap);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsUserJsonKey, json.encode(jsonMap));
    final displayName = (_currentUser?.apelido ?? '').trim().isNotEmpty
        ? _currentUser!.apelido
        : (_currentUser?.nome ?? '');
    await prefs.setString('user_name', displayName);
    await prefs.setString('user_email', _currentUser?.email ?? '');
  }

  Future<void> clear() async {
    _currentUser = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsUserJsonKey);
  }

  static UserModel _buildUserFromBackend(Map<String, dynamic> jsonMap) {
    try {
      final normalized = Map<String, dynamic>.from(jsonMap);

      final role = (normalized['role'] ?? '').toString().trim();
      final computedRole = role.isNotEmpty
          ? role
          : (_isTruthy(normalized['usuarios']) ||
                  _isTruthy(normalized['cadastrausers']) ||
                  _isTruthy(normalized['admin']))
              ? 'ADMIN'
              : 'USER';

      final permissoesApps = _inferPermissoesApps(normalized,
          existing: normalized['permissoesApps']);
      final permissoesLojas = _inferPermissoesLojas(normalized,
          existing: normalized['permissoesLojas']);

      final base = {
        ...normalized,
        'role': computedRole,
        'permissoesApps': permissoesApps,
        'permissoesLojas': permissoesLojas,
      };

      return UserModel.fromJson(base).copyWith(
        role: computedRole,
        permissoesApps: permissoesApps,
        permissoesLojas: permissoesLojas,
      );
    } catch (e) {
      debugPrint('Erro ao processar dados do usuário: $e');
      rethrow;
    }
  }

  static bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    final v = value?.toString().trim().toUpperCase();
    if (v == null) return false;
    return v == 'S' || v == '1' || v == 'TRUE' || v == 'T';
  }

  static List<String> _inferPermissoesApps(
    Map<String, dynamic> jsonMap, {
    dynamic existing,
  }) {
    if (existing is List) {
      return existing.map((e) => e.toString()).toList();
    }

    final inferred = <String>[];

    // Mapeamento baseado no novo formato da API
    for (var module in AppModule.values) {
      if (_isTruthy(jsonMap[module.apiKey])) {
        inferred.add(module.key);
      }
    }

    // Compatibilidade com chaves antigas se necessário
    if (inferred.isEmpty) {
      if (_isTruthy(jsonMap['caddastrocli'])) inferred.add('clientes');
      if (_isTruthy(jsonMap['vertitulos'])) inferred.add('titulos');
      if (_isTruthy(jsonMap['alteralimite'])) inferred.add('limites');
      if (_isTruthy(jsonMap['inadimplencia'])) inferred.add('inadimplencia');
      if (_isTruthy(jsonMap['resumovenda'])) inferred.add('vendas');
      if (_isTruthy(jsonMap['cadastrausers'])) inferred.add('usuarios');
      if (_isTruthy(jsonMap['cancelabaixa'])) inferred.add('baixas');
      if (_isTruthy(jsonMap['rankingvendedor'])) inferred.add('vendedores');
    }

    if (jsonMap['permissoesApps'] is String) {
      final raw = (jsonMap['permissoesApps'] as String).trim();
      if (raw.isNotEmpty) {
        inferred.addAll(
          raw
              .split(',')
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty),
        );
      }
    }

    return inferred.toSet().toList();
  }

  static List<String> _inferPermissoesLojas(
    Map<String, dynamic> jsonMap, {
    dynamic existing,
  }) {
    if (existing is List) {
      return existing.map((e) => e.toString().padLeft(2, '0')).toList();
    }

    final inferred = <String>[];
    for (var i = 1; i <= 32; i++) {
      final loja = i.toString().padLeft(2, '0');
      final key = 'lj$loja';
      final oldKey = 'loja$loja';
      if (_isTruthy(jsonMap[key]) || _isTruthy(jsonMap[oldKey])) {
        inferred.add(loja);
      }
    }

    if (jsonMap['permissoesLojas'] is String) {
      final raw = (jsonMap['permissoesLojas'] as String).trim();
      if (raw.isNotEmpty) {
        inferred.addAll(
          raw
              .split(',')
              .map((e) => e.trim().padLeft(2, '0'))
              .where((e) => e.isNotEmpty),
        );
      }
    }

    return inferred.toSet().toList();
  }
}
