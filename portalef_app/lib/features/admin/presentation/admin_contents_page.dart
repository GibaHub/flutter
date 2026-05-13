import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminContentsProvider = FutureProvider<List<AdminContent>>((ref) async {
  return ref.watch(adminRepositoryProvider).listContents();
});

class AdminContentsPage extends ConsumerWidget {
  const AdminContentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminContentsProvider);

    return AdminScaffold(
      selectedIndex: 4,
      title: 'Conteúdos',
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminContentsProvider);
              await ref.read(adminContentsProvider.future);
            },
            child: asyncList.when(
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum conteúdo encontrado.'),
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
                    final c = items[index];
                    final subtitle = [
                      if (c.materia.isNotEmpty) c.materia,
                      if (c.tipo?.isNotEmpty == true) c.tipo!,
                      if (c.categoria?.isNotEmpty == true) c.categoria!,
                    ].join(' • ');

                    return Card(
                      child: ListTile(
                        title: Text(
                          c.titulo.isEmpty ? 'Conteúdo #${c.id}' : c.titulo,
                        ),
                        subtitle: Text(subtitle),
                        trailing: PopupMenuButton<_ContentAction>(
                          onSelected: (action) async {
                            switch (action) {
                              case _ContentAction.openPdf:
                                final url = c.pdfUrl;
                                if (url == null || url.isEmpty) return;
                                context.go(
                                  '/pdf?url=${Uri.encodeComponent(url)}',
                                );
                              case _ContentAction.edit:
                                context.go(
                                  '/admin/conteudos/${c.id}',
                                  extra: c,
                                );
                              case _ContentAction.delete:
                                final confirmed = await _confirm(
                                  context,
                                  c.titulo,
                                );
                                if (!confirmed) return;
                                try {
                                  await ref
                                      .read(adminRepositoryProvider)
                                      .deleteContent(id: c.id);
                                  ref.invalidate(adminContentsProvider);
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
                              (context) => [
                                if ((c.pdfUrl?.isNotEmpty ?? false))
                                  const PopupMenuItem(
                                    value: _ContentAction.openPdf,
                                    child: Text('Abrir PDF'),
                                  ),
                                const PopupMenuItem(
                                  value: _ContentAction.edit,
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem(
                                  value: _ContentAction.delete,
                                  child: Text('Excluir'),
                                ),
                              ],
                        ),
                        onTap:
                            () => context.go(
                              '/admin/conteudos/${c.id}',
                              extra: c,
                            ),
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
                          'Erro ao carregar conteúdos: $error',
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
              onPressed: () => context.go('/admin/conteudos/novo'),
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

enum _ContentAction { openPdf, edit, delete }

Future<bool> _confirm(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Excluir conteúdo'),
        content: Text('Excluir ${title.isEmpty ? 'este conteúdo' : title}?'),
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
