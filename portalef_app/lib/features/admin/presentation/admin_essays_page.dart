import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminEssaysProvider = FutureProvider<List<AdminEssay>>((ref) async {
  return ref.watch(adminRepositoryProvider).listEssays();
});

class AdminEssaysPage extends ConsumerWidget {
  const AdminEssaysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminEssaysProvider);

    return AdminScaffold(
      selectedIndex: 1,
      title: 'Redações',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminEssaysProvider);
          await ref.read(adminEssaysProvider.future);
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
                      child: Text('Nenhuma redação encontrada.'),
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
                final subtitle = [
                  if (e.dueAt != null) _formatDate(e.dueAt!),
                  'Enviadas: ${e.enviadas}/${e.totalAlunos}',
                  'Corrigidas: ${e.corrigidas}/${e.enviadas}',
                ].join(' • ');

                return Card(
                  child: ListTile(
                    title: Text(e.tema.isEmpty ? 'Redação #${e.id}' : e.tema),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.go('/admin/redacoes/${e.id}');
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
                      'Erro ao carregar redações: $error',
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
