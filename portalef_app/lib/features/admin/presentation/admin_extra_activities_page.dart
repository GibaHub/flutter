import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminExtraActivitiesProvider = FutureProvider<List<AdminExtraActivity>>((
  ref,
) async {
  return ref.watch(adminRepositoryProvider).listExtraActivities();
});

class AdminExtraActivitiesPage extends ConsumerWidget {
  const AdminExtraActivitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminExtraActivitiesProvider);

    return AdminScaffold(
      selectedIndex: 1,
      title: 'Atividades Extras',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminExtraActivitiesProvider);
          await ref.read(adminExtraActivitiesProvider.future);
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
                      child: Text('Nenhuma atividade extra encontrada.'),
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
                  'Enviadas: ${a.enviadas}/${a.totalAlunos}',
                  'Corrigidas: ${a.corrigidas}/${a.enviadas}',
                ].join(' • ');

                return Card(
                  child: ListTile(
                    title: Text(
                      a.titulo.isEmpty ? 'Atividade #${a.id}' : a.titulo,
                    ),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.go('/admin/atividades-extras/${a.id}');
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
