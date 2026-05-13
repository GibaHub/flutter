import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_guardian_links_page.dart';
import 'admin_scaffold.dart';

final guardianManageLinksProvider = FutureProvider.family<
  List<AdminGuardianLink>,
  int
>((ref, guardianId) async {
  final all = await ref.watch(adminRepositoryProvider).listGuardianLinks();
  return all.where((l) => l.guardianId == guardianId).toList(growable: false);
});

final guardianManageStudentsProvider = FutureProvider<List<AdminStudent>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).listStudents();
});

final guardianManageGuardiansProvider = FutureProvider<List<AdminUser>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).getUsers(cargo: 'RESPONSAVEL');
});

class AdminGuardianManagePage extends ConsumerStatefulWidget {
  const AdminGuardianManagePage({super.key, required this.guardianId});

  final int guardianId;

  @override
  ConsumerState<AdminGuardianManagePage> createState() =>
      _AdminGuardianManagePageState();
}

class _AdminGuardianManagePageState
    extends ConsumerState<AdminGuardianManagePage> {
  var _initialized = false;
  final Set<int> _selectedStudentIds = {};
  var _saving = false;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(
      guardianManageLinksProvider(widget.guardianId),
    );
    final studentsAsync = ref.watch(guardianManageStudentsProvider);
    final guardiansAsync = ref.watch(guardianManageGuardiansProvider);

    final guardianName =
        guardiansAsync.valueOrNull
            ?.firstWhere(
              (g) => g.id == widget.guardianId,
              orElse:
                  () => AdminUser(
                    id: widget.guardianId,
                    nome: '',
                    email: '',
                    cargo: '',
                    createdAt: null,
                  ),
            )
            .nome;

    if (!_initialized && linksAsync.hasValue) {
      final ids = linksAsync.value!.map((e) => e.studentId).toSet();
      _selectedStudentIds
        ..clear()
        ..addAll(ids);
      _initialized = true;
    }

    return AdminScaffold(
      selectedIndex: 0,
      title:
          guardianName?.isNotEmpty == true
              ? 'Filhos de $guardianName'
              : 'Filhos do responsável',
      body: studentsAsync.when(
        data: (students) {
          final normalized = _query.trim().toLowerCase();
          final filtered =
              normalized.isEmpty
                  ? students
                  : students
                      .where((s) {
                        final name = s.nome.toLowerCase();
                        final email = s.email.toLowerCase();
                        return name.contains(normalized) ||
                            email.contains(normalized);
                      })
                      .toList(growable: false);

          final selectedCount = _selectedStudentIds.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar aluno',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text('Selecionados: $selectedCount')),
                        TextButton(
                          onPressed:
                              _saving
                                  ? null
                                  : () {
                                    setState(_selectedStudentIds.clear);
                                  },
                          child: const Text('Limpar'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed:
                              _saving
                                  ? null
                                  : () async {
                                    await _save();
                                  },
                          child:
                              _saving
                                  ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: linksAsync.when(
                  data: (currentLinks) {
                    final currentMap = {
                      for (final l in currentLinks) l.studentId: l.id,
                    };

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        final checked = _selectedStudentIds.contains(s.id);
                        return CheckboxListTile(
                          value: checked,
                          onChanged:
                              _saving
                                  ? null
                                  : (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedStudentIds.add(s.id);
                                      } else {
                                        _selectedStudentIds.remove(s.id);
                                      }
                                    });
                                  },
                          title: Text(
                            s.nome.isEmpty ? 'Aluno #${s.id}' : s.nome,
                          ),
                          subtitle: Text(s.email),
                          secondary:
                              currentMap.containsKey(s.id)
                                  ? const Icon(
                                    Icons.link,
                                    color: AppColors.royalBlue,
                                  )
                                  : null,
                        );
                      },
                    );
                  },
                  error:
                      (error, _) => Center(
                        child: Text('Erro ao carregar vínculos: $error'),
                      ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          );
        },
        error:
            (error, _) =>
                Center(child: Text('Erro ao carregar alunos: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final currentLinks = await ref.read(
        guardianManageLinksProvider(widget.guardianId).future,
      );
      final currentStudentIds = currentLinks.map((e) => e.studentId).toSet();
      final currentLinkIdByStudentId = {
        for (final l in currentLinks) l.studentId: l.id,
      };

      final toAdd = _selectedStudentIds
          .difference(currentStudentIds)
          .toList(growable: false);
      final toRemove = currentStudentIds
          .difference(_selectedStudentIds)
          .toList(growable: false);

      for (final studentId in toAdd) {
        await repo.linkStudentToGuardian(
          studentId: studentId,
          guardianId: widget.guardianId,
        );
      }

      for (final studentId in toRemove) {
        final linkId = currentLinkIdByStudentId[studentId];
        if (linkId == null) continue;
        await repo.deleteGuardianLink(id: linkId);
      }

      ref.invalidate(adminGuardianLinksProvider);
      ref.invalidate(guardianManageLinksProvider(widget.guardianId));
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Vínculos atualizados')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Falha ao salvar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
