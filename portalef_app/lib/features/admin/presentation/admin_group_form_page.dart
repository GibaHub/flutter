import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_groups_page.dart';
import 'admin_scaffold.dart';

final adminGroupDetailsProvider = FutureProvider.family<AdminGroupDetails, int>(
  (ref, id) async {
    return ref.watch(adminRepositoryProvider).getGroupDetails(id: id);
  },
);

final adminAllContentsProvider = FutureProvider<List<AdminContent>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).listContents();
});

final adminStudentsProvider = FutureProvider<List<AdminStudent>>((ref) async {
  return ref.watch(adminRepositoryProvider).listStudents();
});

class AdminGroupFormPage extends ConsumerStatefulWidget {
  const AdminGroupFormPage({super.key, required this.groupId});

  final int? groupId;

  @override
  ConsumerState<AdminGroupFormPage> createState() => _AdminGroupFormPageState();
}

class _AdminGroupFormPageState extends ConsumerState<AdminGroupFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  var _saving = false;
  var _prefilled = false;
  var _selectedContentIds = <int>[];
  var _selectedStudentIds = <int>[];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.groupId;
    final isCreate = id == null;
    final title = isCreate ? 'Novo grupo' : 'Editar grupo';

    if (isCreate) {
      return _buildForm(title: title, groupId: null, isCreate: true);
    }

    final asyncDetails = ref.watch(adminGroupDetailsProvider(id));
    return asyncDetails.when(
      data: (details) {
        _prefillIfNeeded(details);
        return _buildForm(title: title, groupId: details.id, isCreate: false);
      },
      error: (error, _) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text('Erro ao carregar grupo: $error')),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  void _prefillIfNeeded(AdminGroupDetails group) {
    if (_prefilled) return;
    _nomeController.text = group.nome;
    _descricaoController.text = group.descricao ?? '';
    _selectedContentIds = group.contentIds;
    _selectedStudentIds = group.studentIds;
    _prefilled = true;
  }

  Widget _buildForm({
    required String title,
    required int? groupId,
    required bool isCreate,
  }) {
    final contentsAsync = ref.watch(adminAllContentsProvider);
    final studentsAsync = ref.watch(adminStudentsProvider);
    final allContents = contentsAsync.valueOrNull ?? const <AdminContent>[];
    final allStudents = studentsAsync.valueOrNull ?? const <AdminStudent>[];

    return AdminScaffold(
      selectedIndex: 3,
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
                  controller: _descricaoController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  enabled: !_saving,
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('Conteúdos vinculados'),
                    subtitle: Text(
                      _selectionSubtitle(
                        selectedIds: _selectedContentIds,
                        labels: allContents
                            .where((c) => _selectedContentIds.contains(c.id))
                            .map(
                              (c) =>
                                  c.titulo.isEmpty
                                      ? 'Conteúdo #${c.id}'
                                      : c.titulo,
                            )
                            .toList(growable: false),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap:
                        _saving
                            ? null
                            : () async {
                              final contents =
                                  contentsAsync.valueOrNull ??
                                  const <AdminContent>[];
                              if (contentsAsync.isLoading) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Carregando conteúdos...'),
                                  ),
                                );
                                return;
                              }
                              if (contentsAsync.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Erro ao carregar conteúdos: ${contentsAsync.error}',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final picked = await _pickContentIds(
                                context,
                                items: contents,
                                selected: _selectedContentIds,
                              );
                              if (picked == null) return;
                              setState(() => _selectedContentIds = picked);
                            },
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Alunos vinculados'),
                    subtitle: Text(
                      _selectionSubtitle(
                        selectedIds: _selectedStudentIds,
                        labels: allStudents
                            .where((s) => _selectedStudentIds.contains(s.id))
                            .map(
                              (s) => s.nome.isEmpty ? 'Aluno #${s.id}' : s.nome,
                            )
                            .toList(growable: false),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap:
                        _saving
                            ? null
                            : () async {
                              final students =
                                  studentsAsync.valueOrNull ??
                                  const <AdminStudent>[];
                              if (studentsAsync.isLoading) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Carregando alunos...'),
                                  ),
                                );
                                return;
                              }
                              if (studentsAsync.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Erro ao carregar alunos: ${studentsAsync.error}',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              final picked = await _pickStudentIds(
                                context,
                                items: students,
                                selected: _selectedStudentIds,
                              );
                              if (picked == null) return;
                              setState(() => _selectedStudentIds = picked);
                            },
                  ),
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
                            await _save(groupId: groupId, isCreate: isCreate);
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

  Future<void> _save({required int? groupId, required bool isCreate}) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final nome = _nomeController.text.trim();
      final descricao = _descricaoController.text.trim();

      if (isCreate) {
        await repo.createGroup(
          nome: nome,
          descricao: descricao.isEmpty ? null : descricao,
          contentIds: _selectedContentIds,
          studentIds: _selectedStudentIds,
        );
      } else {
        await repo.updateGroup(
          id: groupId!,
          nome: nome,
          descricao: descricao.isEmpty ? null : descricao,
          contentIds: _selectedContentIds,
          studentIds: _selectedStudentIds,
        );
      }

      ref.invalidate(adminGroupsProvider);
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

String _selectionSubtitle({
  required List<int> selectedIds,
  required List<String> labels,
}) {
  if (selectedIds.isEmpty) return '0 selecionado(s)';
  final trimmed =
      labels.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  final preview = trimmed.take(3).join(', ');
  final remaining = trimmed.length - 3;
  if (preview.isEmpty) return '${selectedIds.length} selecionado(s)';
  if (remaining > 0) {
    return '${selectedIds.length} selecionado(s): $preview +$remaining';
  }
  return '${selectedIds.length} selecionado(s): $preview';
}

Future<List<int>?> _pickContentIds(
  BuildContext context, {
  required List<AdminContent> items,
  required List<int> selected,
}) async {
  final result = await showDialog<List<int>>(
    context: context,
    builder: (ctx) {
      final current = selected.toSet();
      var query = '';
      return StatefulBuilder(
        builder: (ctx, setState) {
          final normalized = query.trim().toLowerCase();
          final filtered =
              normalized.isEmpty
                  ? items
                  : items
                      .where((c) {
                        final title =
                            (c.titulo.isEmpty ? 'Conteúdo #${c.id}' : c.titulo)
                                .toLowerCase();
                        final subject = c.materia.toLowerCase();
                        return title.contains(normalized) ||
                            subject.contains(normalized);
                      })
                      .toList(growable: false);

          return AlertDialog(
            title: const Text('Selecionar conteúdos'),
            content: SizedBox(
              width: 520,
              height: 520,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final label =
                            c.titulo.isEmpty ? 'Conteúdo #${c.id}' : c.titulo;
                        final isChecked = current.contains(c.id);
                        return CheckboxListTile(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                current.add(c.id);
                              } else {
                                current.remove(c.id);
                              }
                            });
                          },
                          title: Text(label),
                          subtitle: Text(c.materia),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => setState(current.clear),
                child: const Text('Limpar'),
              ),
              FilledButton(
                onPressed:
                    () =>
                        Navigator.of(ctx).pop(current.toList(growable: false)),
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      );
    },
  );
  return result;
}

Future<List<int>?> _pickStudentIds(
  BuildContext context, {
  required List<AdminStudent> items,
  required List<int> selected,
}) async {
  final result = await showDialog<List<int>>(
    context: context,
    builder: (ctx) {
      final current = selected.toSet();
      var query = '';
      return StatefulBuilder(
        builder: (ctx, setState) {
          final normalized = query.trim().toLowerCase();
          final filtered =
              normalized.isEmpty
                  ? items
                  : items
                      .where((s) {
                        final label =
                            (s.nome.isEmpty ? 'Aluno #${s.id}' : s.nome)
                                .toLowerCase();
                        final email = s.email.toLowerCase();
                        return label.contains(normalized) ||
                            email.contains(normalized);
                      })
                      .toList(growable: false);

          return AlertDialog(
            title: const Text('Selecionar alunos'),
            content: SizedBox(
              width: 520,
              height: 520,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        final label =
                            s.nome.isEmpty ? 'Aluno #${s.id}' : s.nome;
                        final isChecked = current.contains(s.id);
                        return CheckboxListTile(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                current.add(s.id);
                              } else {
                                current.remove(s.id);
                              }
                            });
                          },
                          title: Text(label),
                          subtitle: Text(s.email),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => setState(current.clear),
                child: const Text('Limpar'),
              ),
              FilledButton(
                onPressed:
                    () =>
                        Navigator.of(ctx).pop(current.toList(growable: false)),
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      );
    },
  );
  return result;
}
