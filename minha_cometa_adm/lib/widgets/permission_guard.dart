import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes_constants.dart';
import '../services/permission_service.dart';

class PermissionGuard extends StatelessWidget {
  final String module;
  final Widget child;
  final bool requireAdmin;

  const PermissionGuard({
    super.key,
    required this.module,
    required this.child,
    this.requireAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isInitialized || authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authProvider.currentUser;
    if (user == null) {
      return const _AccessDenied();
    }

    if (requireAdmin && user.role.toUpperCase() != 'ADMIN') {
      return const _AccessDenied();
    }

    final permissionService = PermissionService();
    final allowed = permissionService.hasPermission(user, module);

    if (!allowed) {
      return const _AccessDenied();
    }

    return child;
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Acesso Negado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Você não possui permissão para acessar este módulo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Voltar para Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
