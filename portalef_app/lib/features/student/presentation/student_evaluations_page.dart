import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/evaluation_repository.dart';

final evaluationsProvider = FutureProvider<List<EvaluationSummary>>((
  ref,
) async {
  return ref.watch(evaluationRepositoryProvider).list();
});

class StudentEvaluationsPage extends ConsumerWidget {
  const StudentEvaluationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(evaluationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Avaliações')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(evaluationsProvider);
          await ref.read(evaluationsProvider.future);
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
                      child: Text('Nenhuma avaliação encontrada.'),
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
                final e = items[index];
                final isDone = e.status.toUpperCase() == 'CONCLUIDA';
                final subtitle = [
                  if (e.materia.isNotEmpty) e.materia,
                  if (e.serie?.isNotEmpty == true) e.serie!,
                  if (e.scheduledAt != null) _formatDate(e.scheduledAt!),
                  e.status,
                ].join(' • ');

                return Card(
                  child: ListTile(
                    title: Text(
                      e.titulo.isEmpty
                          ? 'Avaliação #${e.evaluationId}'
                          : e.titulo,
                    ),
                    subtitle: Text(subtitle),
                    trailing:
                        isDone
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.play_circle_outline),
                    onTap: () {
                      if (isDone) {
                        context.go(
                          '/aluno/avaliacoes/${e.evaluationId}/resultado',
                        );
                      } else {
                        context.go('/aluno/avaliacoes/${e.evaluationId}');
                      }
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
                      'Erro ao carregar avaliações: $error',
                      style: TextStyle(
                        color: AppColors.darkBg.withValues(alpha: 0.75),
                      ),
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
