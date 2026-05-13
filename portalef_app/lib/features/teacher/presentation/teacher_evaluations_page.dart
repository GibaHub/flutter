import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/teacher_repository.dart';

final teacherEvaluationsProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  return ref.watch(teacherRepositoryProvider).listTeacherEvaluations();
});

class TeacherEvaluationsPage extends ConsumerWidget {
  const TeacherEvaluationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evals = ref.watch(teacherEvaluationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliações')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherEvaluationsProvider);
          await ref.read(teacherEvaluationsProvider.future);
        },
        child: evals.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: const [Text('Nenhuma avaliação cadastrada.')],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = items[index];
                final title = (e['titulo'] as String?) ?? 'Avaliação';
                final materia = (e['materia'] as String?) ?? '';
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
                  child: ListTile(
                    leading: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(PhosphorIconsRegular.clipboardText, color: AppColors.primaryTeal),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(materia, style: const TextStyle(color: AppColors.textSecondary)),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, color: AppColors.textSecondary),
                    onTap: () {},
                  ),
                );
              },
            );
          },
          error: (e, _) => Center(child: Text('Erro: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

