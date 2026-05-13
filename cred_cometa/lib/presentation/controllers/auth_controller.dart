import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _currentCpf;
  String? _currentPhone;
  String? _userName;
  String? _userEmail;
  bool _isAdmin = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  String? _registrationToken;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCpf => _currentCpf;
  String? get currentPhone => _currentPhone;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isAdmin => _isAdmin;
  String? get registrationToken => _registrationToken;

  // Helper to get service token (copied from other repositories logic)
  Future<String> _getServiceToken() async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.authEndpoint}',
        queryParameters: {
          'grant_type': 'password',
          'username': 'cometa.service',
          'password': '103020',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['access_token'];
      } else {
        throw Exception('Failed to authenticate service');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  Future<bool> login(String cpf, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final serviceToken = await _getServiceToken();

      final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.validateUser}',
        data: {"cpf": cleanCpf, "password": password},
        options: Options(
          headers: {
            'Authorization': 'Bearer $serviceToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        _currentCpf = cleanCpf;

        // Parse user data from response
        if (response.data is Map) {
          _userName = response.data['nome'];
          _userEmail = response.data['email'];
          _isAdmin = response.data['admin'] == 'S';
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'CPF ou senha inválidos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        _error = 'CPF ou senha incorretos';
      } else {
        _error = 'Erro ao realizar login: $e';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String birthDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final serviceToken = await _getServiceToken();

      final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      final cleanBirthDate = birthDate.replaceAll(RegExp(r'\D'), '');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.registerCustomer}',
        data: {
          "nome": name.toUpperCase(),
          "email": email,
          "telefone": cleanPhone,
          "cpf": cleanCpf,
          "nascimento": cleanBirthDate,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $serviceToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assume the response body contains the token or is the token
        if (response.data is Map) {
          _registrationToken =
              response.data['token'] ??
              response.data['access_token'] ??
              response.data.toString();
        } else {
          _registrationToken = response.data.toString();
        }

        _currentCpf = cleanCpf;
        _currentPhone = cleanPhone;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Falha no cadastro. Status: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao realizar cadastro: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp(String cpf, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final serviceToken = await _getServiceToken();

      final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.resendToken}',
        data: {"cpf": cleanCpf, "telefone": cleanPhone},
        options: Options(
          headers: {
            'Authorization': 'Bearer $serviceToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Update the registration token with the new one if provided
        if (response.data is Map) {
          final newToken =
              response.data['token'] ??
              response.data['access_token'] ??
              response.data.toString();
          if (newToken != null && newToken.toString().isNotEmpty) {
            _registrationToken = newToken.toString();
          }
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Falha no reenvio. Status: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao reenviar código: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPassword(String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentCpf == null) {
        _error = "CPF não encontrado. Reinicie o cadastro.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final serviceToken = await _getServiceToken();

      final response = await _dio.put(
        '${ApiConstants.baseUrl}${ApiConstants.updatePassword}',
        data: {"cpf": _currentCpf, "password": password},
        options: Options(
          headers: {
            'Authorization': 'Bearer $serviceToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Falha ao criar senha. Status: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao criar senha: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otpCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (_registrationToken == null) {
      _error =
          "Erro de validação: Token não encontrado. Tente reenviar o código.";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (otpCode != _registrationToken) {
      _error = "Código inválido. Verifique o código recebido.";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> authenticateBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para acessar o Cred Cometa',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      _error = "Erro na biometria: $e";
      notifyListeners();
      return false;
    }
  }

  // Biometrics Management
  Future<void> enableBiometrics(String cpf, String password) async {
    await _storage.write(key: 'cpf', value: cpf);
    await _storage.write(key: 'password', value: password);
    await _storage.write(key: 'biometrics_enabled', value: 'true');
  }

  Future<void> disableBiometrics() async {
    await _storage.delete(key: 'cpf');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'biometrics_enabled');
  }

  Future<bool> isBiometricsEnabled() async {
    final enabled = await _storage.read(key: 'biometrics_enabled');
    return enabled == 'true';
  }

  Future<bool> loginWithBiometrics() async {
    final enabled = await isBiometricsEnabled();
    if (!enabled) return false;

    final cpf = await _storage.read(key: 'cpf');
    final password = await _storage.read(key: 'password');

    if (cpf == null || password == null) return false;

    final authenticated = await authenticateBiometrics();
    if (authenticated) {
      return await login(cpf, password);
    }
    return false;
  }

  void logout(BuildContext context) {
    _currentCpf = null;
    _currentPhone = null;
    _userName = null;
    _userEmail = null;
    _isAdmin = false;
    _registrationToken = null;
    notifyListeners();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
