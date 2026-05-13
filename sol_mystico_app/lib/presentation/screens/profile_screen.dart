import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../data/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _authService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Sessão expirada. Faça login novamente.';
        });
        return;
      }

      final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get('/auth/me');
      setState(() {
        _userData = response.data as Map<String, dynamic>;
      });
    } catch (e) {
      setState(() {
        _error = 'Não foi possível carregar o perfil.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userData == null) {
      return const Center(child: Text('Nenhum dado encontrado.'));
    }

    final name = _userData!['name'] ?? 'Usuário';
    final email = _userData!['email'] ?? '';
    final role = _userData!['role'] ?? 'CLIENT';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          _buildInfoTile(Icons.badge, 'Função', role),
          // Adicione mais campos conforme necessário
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.purpleAccent),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
