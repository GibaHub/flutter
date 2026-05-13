import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<String?> getToken() async {
    return await read('access_token'); // Corrigir de 'token' para 'access_token'
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Métodos para gerenciar biometria
  Future<void> saveBiometricCredentials(String email, String password) async {
    await _storage.write(key: 'biometric_email', value: email);
    await _storage.write(key: 'biometric_password', value: password);
    await _storage.write(key: 'biometric_enabled', value: 'true');
  }

  Future<Map<String, String>?> getBiometricCredentials() async {
    final isEnabled = await _storage.read(key: 'biometric_enabled');
    if (isEnabled != 'true') return null;

    final email = await _storage.read(key: 'biometric_email');
    final password = await _storage.read(key: 'biometric_password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: 'biometric_enabled');
    return enabled == 'true';
  }

  Future<void> disableBiometric() async {
    await _storage.delete(key: 'biometric_email');
    await _storage.delete(key: 'biometric_password');
    await _storage.delete(key: 'biometric_enabled');
  }
}
