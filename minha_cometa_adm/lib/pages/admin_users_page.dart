import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../core/app_modules.dart';
import '../models/user_model.dart';
import '../services/users_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final UsersService _usersService = UsersService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<UserModel> _users = <UserModel>[];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users =
          await _usersService.fetchUsers(query: _searchController.text.trim());
      setState(() => _users = users);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openUserForm({UserModel? initial}) async {
    final result = await showModalBottomSheet<_UserFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _UserFormSheet(initial: initial),
    );

    if (result == null) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _usersService.upsertUser(result.user, senha: result.password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários App'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : () => _openUserForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _loadUsers(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadUsers,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadUsers,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final u = _users[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          foregroundColor: AppColors.primary,
                          child: const Icon(Icons.person),
                        ),
                        title: Text(u.nome.isEmpty ? '(Sem nome)' : u.nome),
                        subtitle: Text(u.email),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF0E7ACB),
                        ),
                        onTap: () => _openUserForm(initial: u),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserFormResult {
  final UserModel user;
  final String password;

  const _UserFormResult({required this.user, required this.password});
}

class _UserFormSheet extends StatefulWidget {
  final UserModel? initial;

  const _UserFormSheet({required this.initial});

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _departamentoController = TextEditingController();

  late Set<String> _apps;
  late Set<String> _lojas;

  List<String> get _lojasList =>
      List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nomeController.text = initial?.nome ?? '';
    _emailController.text = initial?.email ?? '';
    _departamentoController.text = initial?.departamento ?? '';
    _apps = (initial?.permissoesApps ?? <String>[])
        .map((e) => e.toLowerCase())
        .toSet();
    _lojas = (initial?.permissoesLojas ?? <String>[])
        .map((e) => e.padLeft(2, '0'))
        .toSet();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _departamentoController.dispose();
    super.dispose();
  }

  void _toggleApp(AppModule module, bool value) {
    setState(() {
      final key = module.key;
      if (value) {
        _apps.add(key);
      } else {
        _apps.remove(key);
      }
    });
  }

  void _toggleLoja(String loja, bool value) {
    setState(() {
      if (value) {
        _lojas.add(loja);
      } else {
        _lojas.remove(loja);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      id: widget.initial?.id ?? '',
      nome: _nomeController.text.trim(),
      apelido: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      departamento: _departamentoController.text.trim(),
      role: _apps.contains(AppModule.usuarios.key) ? 'ADMIN' : 'USER',
      ativo: true,
      permissoesApps: _apps.toList(),
      permissoesLojas: _lojas.toList(),
    );

    Navigator.pop(
      context,
      _UserFormResult(user: user, password: _senhaController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16, bottom: bottomPadding + 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initial == null
                            ? 'Novo Usuário'
                            : 'Editar Usuário',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _departamentoController,
                  decoration: const InputDecoration(
                    labelText: 'Departamento',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Divider(),
                const Text('Módulos',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  child: Column(
                    children: AppModule.values.map((m) {
                      return SwitchListTile(
                        title: Text(m.label),
                        value: _apps.contains(m.key),
                        onChanged: (v) => _toggleApp(m, v),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Lojas',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  child: Column(
                    children: _lojasList.map((loja) {
                      return SwitchListTile(
                        title: Text('Loja $loja'),
                        value: _lojas.contains(loja),
                        onChanged: (v) => _toggleLoja(loja, v),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
