import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/parent_repository.dart';
import 'parent_scaffold.dart';

final parentExtraActivitiesProvider =
    FutureProvider.family<List<ParentExtraActivityItem>, int>((ref, studentId) async {
  return ref.watch(parentRepositoryProvider).getExtraActivities(studentId: studentId);
});

class ParentExtraActivitiesPage extends ConsumerWidget {
  const ParentExtraActivitiesPage({super.key, required this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = studentId;
    if (id == null) {
      return const ParentScaffold(
        selectedIndex: 4,
        title: 'Atividades Extras',
        body: Center(child: Text('studentId ausente')),
      );
    }

    final asyncList = ref.watch(parentExtraActivitiesProvider(id));

    return ParentScaffold(
      selectedIndex: 4,
      title: 'Atividades Extras',
      studentId: id,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentExtraActivitiesProvider(id));
          await ref.read(parentExtraActivitiesProvider(id).future);
        },
        child: asyncList.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  _EmptyState(),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final a = items[index];
                final stripeColor = _statusColor(a.status);
                final subtitle = [
                  if (a.dueAt != null) _formatDate(a.dueAt!),
                  a.status,
                  if (a.score != null) 'Nota: ${a.score}',
                ].join(' • ');

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
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 96,
                        decoration: BoxDecoration(
                          color: stripeColor,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.clipboardText,
                                    color: stripeColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      a.titulo.isEmpty ? 'Atividade #${a.activityId}' : a.titulo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                              if (a.feedback?.trim().isNotEmpty == true) ...[
                                const SizedBox(height: 10),
                                Text(
                                  a.feedback!.trim(),
                                  style: TextStyle(
                                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                );
              },
            );
          },
          error: (error, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro ao carregar atividades: $error'),
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
              PhosphorIconsRegular.clipboardText,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nenhuma atividade encontrada.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  final s = status.trim().toUpperCase();
  if (s.contains('CONCLU') || s.contains('CORRIG')) return AppColors.success;
  if (s.contains('ATRAS')) return AppColors.error;
  if (s.contains('PEND') || s.contains('AGUARD')) return AppColors.primaryTeal;
  return AppColors.primaryTeal;
}

String _formatDate(DateTime date) {
  final d = date.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}
