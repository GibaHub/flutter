import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_groups_page.dart';
import 'admin_scaffold.dart';

final adminGroupDetailsByIdProvider =
    FutureProvider.family<AdminGroupDetails, int>((ref, groupId) async {
      return ref.watch(adminRepositoryProvider).getGroupDetails(id: groupId);
    });

final adminAllContentsProvider = FutureProvider<List<AdminContent>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).listContents();
});

final adminAllStudentsProvider = FutureProvider<List<AdminStudent>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).listStudents();
});

class AdminGroupDetailsPage extends ConsumerWidget {
  const AdminGroupDetailsPage({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(adminGroupDetailsByIdProvider(groupId));
    final contentsAsync = ref.watch(adminAllContentsProvider);
    final studentsAsync = ref.watch(adminAllStudentsProvider);

    return AdminScaffold(
      selectedIndex: 3,
      title: 'Detalhe do grupo',
      actions: [
        IconButton(
          tooltip: 'Editar',
          onPressed: () => context.go('/admin/grupos/$groupId'),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminGroupDetailsByIdProvider(groupId));
          await ref.read(adminGroupDetailsByIdProvider(groupId).future);
        },
        child: detailsAsync.when(
          data: (details) {
            final allContents =
                contentsAsync.valueOrNull ?? const <AdminContent>[];
            final allStudents =
                studentsAsync.valueOrNull ?? const <AdminStudent>[];

            final contentById = {for (final c in allContents) c.id: c};
            final studentById = {for (final s in allStudents) s.id: s};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.nome.isEmpty
                              ? 'Grupo #${details.id}'
                              : details.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (details.descricao ?? '').trim().isEmpty
                              ? '—'
                              : details.descricao!.trim(),
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conteúdos vinculados',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        if (details.contentIds.isEmpty)
                          Text(
                            'Nenhum conteúdo',
                            style: TextStyle(
                              color: AppColors.darkBg.withValues(alpha: 0.7),
                            ),
                          )
                        else
                          for (final id in details.contentIds)
                            _RemovableRow(
                              title:
                                  (contentById[id]?.titulo.isNotEmpty ?? false)
                                      ? contentById[id]!.titulo
                                      : 'Conteúdo #$id',
                              subtitle: contentById[id]?.materia ?? '',
                              onRemove: () async {
                                final next = details.contentIds
                                    .where((e) => e != id)
                                    .toList(growable: false);
                                await _saveLinks(
                                  context,
                                  ref,
                                  details: details,
                                  contentIds: next,
                                  studentIds: details.studentIds,
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alunos vinculados',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        if (details.studentIds.isEmpty)
                          Text(
                            'Nenhum aluno',
                            style: TextStyle(
                              color: AppColors.darkBg.withValues(alpha: 0.7),
                            ),
                          )
                        else
                          for (final id in details.studentIds)
                            _RemovableRow(
                              title:
                                  (studentById[id]?.nome.isNotEmpty ?? false)
                                      ? studentById[id]!.nome
                                      : 'Aluno #$id',
                              subtitle: studentById[id]?.email ?? '',
                              onRemove: () async {
                                final next = details.studentIds
                                    .where((e) => e != id)
                                    .toList(growable: false);
                                await _saveLinks(
                                  context,
                                  ref,
                                  details: details,
                                  contentIds: details.contentIds,
                                  studentIds: next,
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          error: (error, _) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro ao carregar grupo: $error'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<void> _saveLinks(
    BuildContext context,
    WidgetRef ref, {
    required AdminGroupDetails details,
    required List<int> contentIds,
    required List<int> studentIds,
  }) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateGroup(
            id: details.id,
            nome: details.nome,
            descricao: details.descricao,
            contentIds: contentIds,
            studentIds: studentIds,
          );
      ref.invalidate(adminGroupDetailsByIdProvider(details.id));
      ref.invalidate(adminGroupsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vínculos atualizados')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao atualizar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _RemovableRow extends StatelessWidget {
  const _RemovableRow({
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle.trim().isEmpty ? null : Text(subtitle),
      trailing: IconButton(
        tooltip: 'Remover',
        onPressed: onRemove,
        icon: const Icon(Icons.close),
      ),
    );
  }
}
