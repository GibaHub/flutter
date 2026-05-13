import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'portalef.jwt';
  static const _userKey = 'portalef.user';
  static const _biometricEnabledKey = 'portalef.biometric.enabled';
  static const _viewedContentPrefix = 'portalef.viewedContents.';
  static const _lastOpenedContentPrefix = 'portalef.lastOpenedContent.';

  Future<void> writeToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {}
  }

  Future<String?> readToken() async {
    try {
      return await _storage
          .read(key: _tokenKey)
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUserJson(String json) async {
    try {
      await _storage.write(key: _userKey, value: json);
    } catch (_) {}
  }

  Future<String?> readUserJson() async {
    try {
      return await _storage
          .read(key: _userKey)
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (_) {}
  }

  Future<void> writeBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey,
        value: enabled ? '1' : '0',
      );
    } catch (_) {}
  }

  Future<bool> readBiometricEnabled() async {
    try {
      final value = await _storage
          .read(key: _biometricEnabledKey)
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
      return value == '1';
    } catch (_) {
      return false;
    }
  }

  Future<Set<int>> readViewedContentIds({required int userId}) async {
    try {
      final raw = await _storage
          .read(key: '$_viewedContentPrefix$userId')
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
      if (raw == null || raw.isEmpty) return <int>{};
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <int>{};
      return decoded.whereType<num>().map((e) => e.toInt()).toSet();
    } catch (_) {
      return <int>{};
    }
  }

  Future<void> writeViewedContentIds({
    required int userId,
    required Set<int> ids,
  }) async {
    try {
      final raw = jsonEncode(ids.toList(growable: false));
      await _storage.write(key: '$_viewedContentPrefix$userId', value: raw);
    } catch (_) {}
  }

  Future<int?> readLastOpenedContentId({required int userId}) async {
    try {
      final raw = await _storage
          .read(key: '$_lastOpenedContentPrefix$userId')
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
      if (raw == null || raw.trim().isEmpty) return null;
      return int.tryParse(raw.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> writeLastOpenedContentId({
    required int userId,
    required int contentId,
  }) async {
    try {
      await _storage.write(
        key: '$_lastOpenedContentPrefix$userId',
        value: contentId.toString(),
      );
    } catch (_) {}
  }
}
