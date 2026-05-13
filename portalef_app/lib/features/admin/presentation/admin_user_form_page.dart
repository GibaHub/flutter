import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_users_page.dart';
import 'admin_scaffold.dart';

final adminUserByIdProvider = FutureProvider.family<AdminUser, int>((
  ref,
  id,
) async {
  final users = await ref.watch(adminRepositoryProvider).getUsers();
  return users.firstWhere((u) => u.id == id);
});

class AdminUserFormPage extends ConsumerStatefulWidget {
  const AdminUserFormPage({
    super.key,
    required this.userId,
    required this.initialUser,
  });

  final int? userId;
  final AdminUser? initialUser;

  @override
  ConsumerState<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends ConsumerState<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  var _cargo = 'ALUNO';
  var _saving = false;
  var _prefilled = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.userId;
    final isCreate = id == null;
    final title = isCreate ? 'Novo usuário' : 'Editar usuário';

    final initial = widget.initialUser;
    if (initial != null) {
      _prefillIfNeeded(initial);
      return _buildForm(title: title, userId: initial.id, isCreate: isCreate);
    }

    if (isCreate) {
      return _buildForm(title: title, userId: null, isCreate: true);
    }

    final asyncUser = ref.watch(adminUserByIdProvider(id));
    return asyncUser.when(
      data: (user) {
        _prefillIfNeeded(user);
        return _buildForm(title: title, userId: user.id, isCreate: false);
      },
      error: (error, _) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text('Erro ao carregar usuário: $error')),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  void _prefillIfNeeded(AdminUser user) {
    if (_prefilled) return;
    _nomeController.text = user.nome;
    _emailController.text = user.email;
    _cargo = user.cargo.isEmpty ? 'ALUNO' : user.cargo;
    _prefilled = true;
  }

  Widget _buildForm({
    required String title,
    required int? userId,
    required bool isCreate,
  }) {
    return AdminScaffold(
      selectedIndex: 2,
      title: title,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Informe o nome';
                    return null;
                  },
                  enabled: !_saving,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Informe o e-mail';
                    if (!text.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                  enabled: !_saving,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _cargo,
                  items: const [
                    DropdownMenuItem(value: 'ALUNO', child: Text('ALUNO')),
                    DropdownMenuItem(
                      value: 'RESPONSAVEL',
                      child: Text('RESPONSAVEL'),
                    ),
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  ],
                  onChanged:
                      _saving
                          ? null
                          : (value) {
                            if (value == null) return;
                            setState(() => _cargo = value);
                          },
                  decoration: const InputDecoration(labelText: 'Cargo'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isCreate ? 'Senha' : 'Senha (opcional)',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (isCreate && text.isEmpty) return 'Informe a senha';
                    return null;
                  },
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed:
                      _saving
                          ? null
                          : () async {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            await _save(userId: userId, isCreate: isCreate);
                          },
                  child:
                      _saving
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save({required int? userId, required bool isCreate}) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final nome = _nomeController.text.trim();
      final email = _emailController.text.trim();
      final senha = _senhaController.text.trim();

      if (isCreate) {
        await repo.createUser(
          nome: nome,
          email: email,
          senha: senha,
          cargo: _cargo,
        );
      } else {
        await repo.updateUser(
          id: userId!,
          nome: nome,
          email: email,
          cargo: _cargo,
          senha: senha.isEmpty ? null : senha,
        );
      }

      ref.invalidate(adminUsersProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (mounted) setState(() => _saving = false);
    }
  }
}
