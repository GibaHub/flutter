import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) async {
  return ref.watch(adminRepositoryProvider).getUsers();
});

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(adminUsersProvider);

    return AdminScaffold(
      selectedIndex: 2,
      title: 'Usuários',
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminUsersProvider);
              await ref.read(adminUsersProvider.future);
            },
            child: asyncUsers.when(
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum usuário encontrado.'),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final u = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          u.nome.isEmpty ? 'Usuário #${u.id}' : u.nome,
                        ),
                        subtitle: Text('${u.email} • ${u.cargo}'),
                        trailing: PopupMenuButton<_UserAction>(
                          onSelected: (action) async {
                            switch (action) {
                              case _UserAction.edit:
                                context.go('/admin/usuarios/${u.id}', extra: u);
                              case _UserAction.delete:
                                final confirmed = await _confirm(
                                  context,
                                  u.nome,
                                );
                                if (!confirmed) return;
                                try {
                                  await ref
                                      .read(adminRepositoryProvider)
                                      .deleteUser(id: u.id);
                                  ref.invalidate(adminUsersProvider);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Falha ao excluir: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                            }
                          },
                          itemBuilder:
                              (context) => const [
                                PopupMenuItem(
                                  value: _UserAction.edit,
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: _UserAction.delete,
                                  child: Text('Excluir'),
                                ),
                              ],
                        ),
                        onTap:
                            () =>
                                context.go('/admin/usuarios/${u.id}', extra: u),
                      ),
                    );
                  },
                );
              },
              error: (error, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Erro ao carregar usuários: $error',
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => context.go('/admin/usuarios/novo'),
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

enum _UserAction { edit, delete }

Future<bool> _confirm(BuildContext context, String name) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Excluir usuário'),
        content: Text('Excluir ${name.isEmpty ? 'este usuário' : name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
