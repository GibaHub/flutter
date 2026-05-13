import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/parent_repository.dart';
import '../domain/parent_student.dart';
import 'parent_scaffold.dart';

final parentStudentsProvider = FutureProvider<List<ParentStudent>>((ref) async {
  return ref.watch(parentRepositoryProvider).getStudents();
});

class ParentHomePage extends ConsumerStatefulWidget {
  const ParentHomePage({super.key});

  @override
  ConsumerState<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends ConsumerState<ParentHomePage> {
  int? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final students = ref.watch(parentStudentsProvider);

    return ParentScaffold(
      selectedIndex: 2,
      title: 'Dashboard',
      actions: [
        IconButton(
          tooltip: 'Sair',
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).logout();
          },
          icon: const Icon(PhosphorIconsRegular.signOut),
        ),
      ],
      studentId: _selectedStudentId,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentStudentsProvider);
          await ref.read(parentStudentsProvider.future);
        },
        child: students.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: const [_EmptyState()],
              );
            }

            final resolvedSelectedId = _selectedStudentId ?? items.first.id;
            if (_selectedStudentId == null ||
                !_containsStudent(items, resolvedSelectedId)) {
              _selectedStudentId = resolvedSelectedId;
            }
            final selected = items.firstWhere(
              (e) => e.id == resolvedSelectedId,
            );

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _WelcomeHeader(name: session?.user.name ?? ''),
                const SizedBox(height: 18),
                const Text(
                  'Meus alunos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 118,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final s = items[index];
                      final isSelected = s.id == resolvedSelectedId;
                      return _StudentPickerCard(
                        student: s,
                        selected: isSelected,
                        onTap: () => setState(() => _selectedStudentId = s.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _StudentFocusCard(student: selected),
                const SizedBox(height: 14),
                const Text(
                  'Ações rápidas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.65,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ActionCard(
                      title: 'Boletim',
                      icon: PhosphorIconsRegular.scroll,
                      onTap:
                          () => context.go(
                            '/responsavel/boletim?studentId=${selected.id}',
                          ),
                    ),
                    _ActionCard(
                      title: 'Estatísticas',
                      icon: PhosphorIconsRegular.chartBar,
                      onTap:
                          () => context.go(
                            '/responsavel/stats?studentId=${selected.id}',
                          ),
                    ),
                    _ActionCard(
                      title: 'Redações',
                      icon: PhosphorIconsRegular.notePencil,
                      onTap:
                          () => context.go(
                            '/responsavel/redacoes?studentId=${selected.id}',
                          ),
                    ),
                    _ActionCard(
                      title: 'Atividades',
                      icon: PhosphorIconsRegular.clipboardText,
                      onTap:
                          () => context.go(
                            '/responsavel/atividades-extras?studentId=${selected.id}',
                          ),
                    ),
                  ],
                ),
              ],
            );
          },
          error: (error, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ErrorCard(message: 'Erro ao carregar alunos: $error'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

bool _containsStudent(List<ParentStudent> items, int id) {
  for (final s in items) {
    if (s.id == id) return true;
  }
  return false;
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Responsável' : name.trim();
    final initials =
        displayName
            .split(' ')
            .where((p) => p.trim().isNotEmpty)
            .take(2)
            .map((p) => p.trim()[0].toUpperCase())
            .join();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $displayName',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Acompanhe o desempenho e as entregas.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.12),
          foregroundColor: AppColors.primaryTeal,
          child: Text(
            initials.isEmpty ? 'R' : initials,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _StudentPickerCard extends StatelessWidget {
  const _StudentPickerCard({
    required this.student,
    required this.selected,
    required this.onTap,
  });

  final ParentStudent student;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryTeal : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                PhosphorIconsRegular.user,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    student.nome.isEmpty ? 'Aluno ${student.id}' : student.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentFocusCard extends StatelessWidget {
  const _StudentFocusCard({required this.student});

  final ParentStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTeal,
            AppColors.primaryTeal.withValues(alpha: 0.72),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.student, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nome.isEmpty ? 'Aluno ${student.id}' : student.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primaryTeal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              PhosphorIconsRegular.usersThree,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nenhum aluno vinculado foi encontrado.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Text(message),
    );
  }
}
