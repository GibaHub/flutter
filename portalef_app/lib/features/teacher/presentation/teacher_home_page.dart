import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/teacher_repository.dart';

final teacherDashboardProvider = FutureProvider<Map<String, Object?>>((ref) async {
  return ref.watch(teacherRepositoryProvider).getDashboard();
});

class TeacherHomePage extends ConsumerWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final dash = ref.watch(teacherDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Professor')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherDashboardProvider);
          await ref.read(teacherDashboardProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Header(name: session?.user.name ?? ''),
            const SizedBox(height: 14),
            dash.when(
              data: (data) {
                final overview = (data['overview'] as Map?) ?? const {};
                final studentsCount = overview['studentsCount'] ?? 0;
                final avgScore = (overview['avgScoreLast30Days'] ?? 0).toString();
                final pending = (overview['pending'] as Map?) ?? const {};
                return GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _Kpi(label: 'Alunos', value: '$studentsCount', icon: PhosphorIconsRegular.users),
                    _Kpi(label: 'Média 30d', value: avgScore, icon: PhosphorIconsRegular.chartLineUp),
                    _Kpi(label: 'Pendências', value: '${pending['evaluations'] ?? 0}', icon: PhosphorIconsRegular.clipboardText),
                    _Kpi(label: 'Redações', value: '${pending['essays'] ?? 0}', icon: PhosphorIconsRegular.notePencil),
                  ],
                );
              },
              error: (e, _) => Text('Erro: $e'),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final display = name.trim().isEmpty ? 'Professor' : name.trim();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.primaryTeal.withValues(alpha: 0.72)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(PhosphorIconsRegular.chalkboardTeacher, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Painel do professor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(display, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

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
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

