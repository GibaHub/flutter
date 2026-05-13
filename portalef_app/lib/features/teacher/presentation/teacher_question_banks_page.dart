import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/teacher_repository.dart';

final teacherQuestionBanksProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  return ref.watch(teacherRepositoryProvider).listQuestionBanks();
});

class TeacherQuestionBanksPage extends ConsumerWidget {
  const TeacherQuestionBanksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banks = ref.watch(teacherQuestionBanksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bancos de Questões')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherQuestionBanksProvider);
          await ref.read(teacherQuestionBanksProvider.future);
        },
        child: banks.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: const [Text('Nenhum banco disponível.')],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = items[index];
                final id = (b['id'] as num?)?.toInt();
                final titulo = (b['titulo'] as String?) ?? 'Banco';
                final materia = (b['materia'] as String?) ?? '';
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
                      child: const Icon(PhosphorIconsRegular.books, color: AppColors.primaryTeal),
                    ),
                    title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(materia, style: const TextStyle(color: AppColors.textSecondary)),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, color: AppColors.textSecondary),
                    onTap: id == null ? null : () {},
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

