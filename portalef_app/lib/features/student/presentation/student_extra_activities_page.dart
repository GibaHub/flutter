import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/extra_activity_repository.dart';

final studentExtraActivitiesProvider =
    FutureProvider<List<StudentExtraActivityListItem>>((ref) async {
  return ref.watch(extraActivityRepositoryProvider).list();
});

class StudentExtraActivitiesPage extends ConsumerWidget {
  const StudentExtraActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(studentExtraActivitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Atividades Extras')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentExtraActivitiesProvider);
          await ref.read(studentExtraActivitiesProvider.future);
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
                      child: Text('Nenhuma atividade extra disponível.'),
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
                final a = items[index];
                final subtitle = [
                  if (a.dueAt != null) _formatDate(a.dueAt!),
                  a.status,
                  if (a.score != null) 'Nota: ${a.score}',
                ].join(' • ');

                return Card(
                  child: ListTile(
                    title: Text(a.titulo.isEmpty ? 'Atividade #${a.activityId}' : a.titulo),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.go('/aluno/atividades-extras/${a.activityId}');
                    },
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
                      'Erro ao carregar atividades: $error',
                      style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.75)),
                    ),
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
}

String _formatDate(DateTime date) {
  final d = date.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}

