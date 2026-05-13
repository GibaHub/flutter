import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return ref.watch(adminRepositoryProvider).getStats();
});

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final statsAsync = ref.watch(adminStatsProvider);

    return AdminScaffold(
      selectedIndex: 0,
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Header(
            name: session?.user.name ?? '',
          ),
          const SizedBox(height: 12),
          statsAsync.when(
            data: (stats) {
              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _KpiCard(
                    title: 'Alunos',
                    value: stats.totalAlunos.toString(),
                    icon: PhosphorIconsRegular.users,
                  ),
                  _KpiCard(
                    title: 'Matérias',
                    value: stats.materiasAtivas.toString(),
                    icon: PhosphorIconsRegular.bookOpen,
                  ),
                  _KpiCard(
                    title: 'Questões',
                    value: stats.questoesCadastradas.toString(),
                    icon: PhosphorIconsRegular.question,
                  ),
                  _KpiCard(
                    title: 'Vínculos',
                    value: 'Gerenciar',
                    icon: PhosphorIconsRegular.link,
                    onTap: () => context.go('/admin/vinculos'),
                  ),
                ],
              );
            },
            error: (error, _) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erro ao carregar stats: $error'),
                ),
              );
            },
            loading: () {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _QuickActions(onGo: (path) => context.go(path)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Admin' : name.trim();
    final initials = displayName
        .split(' ')
        .where((p) => p.trim().isNotEmpty)
        .take(2)
        .map((p) => p.trim()[0].toUpperCase())
        .join();

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
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $displayName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Acompanhe indicadores e gerencie a plataforma.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            foregroundColor: Colors.white,
            child: Text(
              initials.isEmpty ? 'A' : initials,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onGo});

  final void Function(String path) onGo;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionItem(
        title: 'Redações',
        subtitle: 'Correções',
        icon: PhosphorIconsRegular.notePencil,
        path: '/admin/redacoes',
      ),
      _ActionItem(
        title: 'Atividades',
        subtitle: 'Extras',
        icon: PhosphorIconsRegular.clipboardText,
        path: '/admin/atividades-extras',
      ),
      _ActionItem(
        title: 'Usuários',
        subtitle: 'CRUD',
        icon: PhosphorIconsRegular.users,
        path: '/admin/usuarios',
      ),
      _ActionItem(
        title: 'Grupos',
        subtitle: 'Turmas',
        icon: PhosphorIconsRegular.usersThree,
        path: '/admin/grupos',
      ),
      _ActionItem(
        title: 'Conteúdos',
        subtitle: 'Materiais',
        icon: PhosphorIconsRegular.bookOpen,
        path: '/admin/conteudos',
      ),
      _ActionItem(
        title: 'Vínculos',
        subtitle: 'Resp x Aluno',
        icon: PhosphorIconsRegular.link,
        path: '/admin/vinculos',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            for (final i in items)
              _ActionCard(
                title: i.title,
                subtitle: i.subtitle,
                icon: i.icon,
                onTap: () => onGo(i.path),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.path,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String path;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
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
