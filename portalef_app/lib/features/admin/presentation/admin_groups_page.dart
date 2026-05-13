import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminGroupsProvider = FutureProvider<List<AdminGroup>>((ref) async {
  return ref.watch(adminRepositoryProvider).listGroups();
});

class AdminGroupsPage extends ConsumerWidget {
  const AdminGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(adminGroupsProvider);

    return AdminScaffold(
      selectedIndex: 3,
      title: 'Grupos',
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminGroupsProvider);
              await ref.read(adminGroupsProvider.future);
            },
            child: asyncGroups.when(
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum grupo encontrado.'),
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
                    final g = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(g.nome.isEmpty ? 'Grupo #${g.id}' : g.nome),
                        subtitle: Text(
                          (g.descricao ?? '').trim().isEmpty
                              ? '—'
                              : g.descricao!.trim(),
                        ),
                        trailing: PopupMenuButton<_GroupAction>(
                          onSelected: (action) async {
                            switch (action) {
                              case _GroupAction.details:
                                context.go('/admin/grupos/${g.id}/detalhes');
                              case _GroupAction.edit:
                                context.go('/admin/grupos/${g.id}');
                              case _GroupAction.delete:
                                final confirmed = await _confirm(
                                  context,
                                  g.nome,
                                );
                                if (!confirmed) return;
                                try {
                                  await ref
                                      .read(adminRepositoryProvider)
                                      .deleteGroup(id: g.id);
                                  ref.invalidate(adminGroupsProvider);
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
                                  value: _GroupAction.details,
                                  child: Text('Detalhes'),
                                ),
                                PopupMenuItem(
                                  value: _GroupAction.edit,
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: _GroupAction.delete,
                                  child: Text('Excluir'),
                                ),
                              ],
                        ),
                        onTap:
                            () => context.go('/admin/grupos/${g.id}/detalhes'),
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
                          'Erro ao carregar grupos: $error',
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
              onPressed: () => context.go('/admin/grupos/novo'),
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

enum _GroupAction { details, edit, delete }

Future<bool> _confirm(BuildContext context, String name) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Excluir grupo'),
        content: Text('Excluir ${name.isEmpty ? 'este grupo' : name}?'),
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
