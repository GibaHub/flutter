import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminGuardianLinksProvider = FutureProvider<List<AdminGuardianLink>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).listGuardianLinks();
});

final adminGuardiansProvider = FutureProvider<List<AdminUser>>((ref) async {
  return ref.watch(adminRepositoryProvider).getUsers(cargo: 'RESPONSAVEL');
});

final adminStudentsProvider = FutureProvider<List<AdminStudent>>((ref) async {
  return ref.watch(adminRepositoryProvider).listStudents();
});

class AdminGuardianLinksPage extends ConsumerStatefulWidget {
  const AdminGuardianLinksPage({super.key});

  @override
  ConsumerState<AdminGuardianLinksPage> createState() =>
      _AdminGuardianLinksPageState();
}

class _AdminGuardianLinksPageState
    extends ConsumerState<AdminGuardianLinksPage> {
  int? _filterGuardianId;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(adminGuardianLinksProvider);
    final guardiansAsync = ref.watch(adminGuardiansProvider);

    return AdminScaffold(
      selectedIndex: 0,
      title: 'Vínculos',
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminGuardianLinksProvider);
              await ref.read(adminGuardianLinksProvider.future);
            },
            child: linksAsync.when(
              data: (items) {
                final filtered = _applyFilters(items);

                if (items.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhum vínculo cadastrado.'),
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            guardiansAsync.when(
                              data: (guardians) {
                                final selected = _findGuardian(
                                  guardians,
                                  _filterGuardianId,
                                );
                                return DropdownButtonFormField<AdminUser?>(
                                  value: selected,
                                  items: [
                                    const DropdownMenuItem<AdminUser?>(
                                      value: null,
                                      child: Text('Todos os responsáveis'),
                                    ),
                                    ...guardians.map(
                                      (g) => DropdownMenuItem<AdminUser?>(
                                        value: g,
                                        child: Text(
                                          g.nome.isEmpty
                                              ? 'Responsável #${g.id}'
                                              : g.nome,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    setState(() {
                                      _filterGuardianId = v?.id;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Filtrar por responsável',
                                  ),
                                );
                              },
                              error:
                                  (error, _) => Text(
                                    'Erro ao carregar responsáveis: $error',
                                  ),
                              loading: () => const LinearProgressIndicator(),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Buscar vínculo',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (v) => setState(() => _query = v),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonalIcon(
                              onPressed:
                                  _filterGuardianId == null
                                      ? null
                                      : () {
                                        context.go(
                                          '/admin/vinculos/${_filterGuardianId!}',
                                        );
                                      },
                              icon: const Icon(Icons.manage_accounts_outlined),
                              label: const Text(
                                'Gerenciar filhos do responsável',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total: ${filtered.length}',
                              style: TextStyle(
                                color: AppColors.darkBg.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum vínculo encontrado para os filtros atuais.',
                          ),
                        ),
                      )
                    else
                      ...filtered.map((link) => _LinkCard(link: link)),
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
                        child: Text('Erro ao carregar vínculos: $error'),
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
              onPressed: () async {
                await _openCreateDialog(context, ref);
              },
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  List<AdminGuardianLink> _applyFilters(List<AdminGuardianLink> items) {
    final normalized = _query.trim().toLowerCase();
    return items
        .where((l) {
          if (_filterGuardianId != null && l.guardianId != _filterGuardianId) {
            return false;
          }
          if (normalized.isEmpty) return true;
          final g = l.guardianName.toLowerCase();
          final s = l.studentName.toLowerCase();
          return g.contains(normalized) || s.contains(normalized);
        })
        .toList(growable: false);
  }

  AdminUser? _findGuardian(List<AdminUser> guardians, int? id) {
    if (id == null) return null;
    for (final g in guardians) {
      if (g.id == id) return g;
    }
    return null;
  }
}

class _LinkCard extends ConsumerWidget {
  const _LinkCard({required this.link});

  final AdminGuardianLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          link.guardianName.isEmpty
              ? 'Responsável #${link.guardianId}'
              : link.guardianName,
        ),
        subtitle: Text(
          link.studentName.isEmpty
              ? 'Aluno #${link.studentId}'
              : link.studentName,
        ),
        trailing: IconButton(
          tooltip: 'Excluir vínculo',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirmed = await _confirmDelete(context, link);
            if (!confirmed) return;
            try {
              await ref
                  .read(adminRepositoryProvider)
                  .deleteGuardianLink(id: link.id);
              ref.invalidate(adminGuardianLinksProvider);
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
          },
        ),
      ),
    );
  }
}

Future<void> _openCreateDialog(BuildContext context, WidgetRef ref) async {
  final guardiansAsync = await ref
      .read(adminGuardiansProvider.future)
      .then((v) => v)
      .catchError((_) => <AdminUser>[]);
  final studentsAsync = await ref
      .read(adminStudentsProvider.future)
      .then((v) => v)
      .catchError((_) => <AdminStudent>[]);
  if (!context.mounted) return;

  AdminUser? guardian;
  AdminStudent? student;
  var saving = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Criar vínculo'),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AdminUser>(
                    value: guardian,
                    items: guardiansAsync
                        .map(
                          (g) => DropdownMenuItem(
                            value: g,
                            child: Text(
                              g.nome.isEmpty ? 'Responsável #${g.id}' : g.nome,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged:
                        saving ? null : (v) => setState(() => guardian = v),
                    decoration: const InputDecoration(labelText: 'Responsável'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AdminStudent>(
                    value: student,
                    items: studentsAsync
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.nome.isEmpty ? 'Aluno #${s.id}' : s.nome,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged:
                        saving ? null : (v) => setState(() => student = v),
                    decoration: const InputDecoration(labelText: 'Aluno'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed:
                    saving || guardian == null || student == null
                        ? null
                        : () async {
                          setState(() => saving = true);
                          try {
                            await ref
                                .read(adminRepositoryProvider)
                                .linkStudentToGuardian(
                                  studentId: student!.id,
                                  guardianId: guardian!.id,
                                );
                            ref.invalidate(adminGuardianLinksProvider);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Falha ao criar vínculo: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                            setState(() => saving = false);
                          }
                        },
                child:
                    saving
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Salvar'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<bool> _confirmDelete(
  BuildContext context,
  AdminGuardianLink link,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Excluir vínculo'),
        content: Text(
          'Excluir vínculo entre ${link.guardianName} e ${link.studentName}?',
        ),
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
