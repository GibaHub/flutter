import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/storage/last_opened_content_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/storage/viewed_contents_controller.dart';
import '../data/student_repository.dart';
import '../domain/study_group.dart';

final studentGroupsProvider = FutureProvider<List<StudyGroup>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getMyGroups();
});

class StudentContentsPage extends ConsumerWidget {
  const StudentContentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final groups = ref.watch(studentGroupsProvider);
    final viewedAsync =
        session == null
            ? const AsyncValue.data(<int>{})
            : ref.watch(viewedContentsControllerProvider(session.user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Trilha de aprendizado')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentGroupsProvider);
          await ref.read(studentGroupsProvider.future);
        },
        child: groups.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhum grupo encontrado para este aluno.'),
                    ),
                  ),
                ],
              );
            }

            return viewedAsync.when(
              data: (viewedIds) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final group = items[index];
                    return _GroupCard(
                      group: group,
                      viewedIds: viewedIds,
                      userId: session?.user.id,
                    );
                  },
                );
              },
              error: (_, __) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final group = items[index];
                    return _GroupCard(
                      group: group,
                      viewedIds: const <int>{},
                      userId: session?.user.id,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
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
                      'Erro ao carregar conteúdos: $error',
                      style: TextStyle(
                        color: AppColors.darkBg.withValues(alpha: 0.8),
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

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.viewedIds,
    required this.userId,
  });

  final StudyGroup group;
  final Set<int> viewedIds;
  final int? userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                group.nome.isEmpty ? 'Grupo ${group.id}' : group.nome,
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (group.contents.isEmpty)
              const Text(
                'Sem conteúdos',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...group.contents.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityCard(
                    content: c,
                    viewed: viewedIds.contains(c.id),
                    userId: userId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard({
    required this.content,
    required this.viewed,
    required this.userId,
  });

  final StudyContent content;
  final bool viewed;
  final int? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf =
        content.tipo.toUpperCase() == 'PDF' ||
        (content.pdfUrl?.isNotEmpty ?? false);
    final canOpenPdf = isPdf && (content.pdfUrl?.isNotEmpty ?? false);
    final canStudy =
        (content.pdfUrl?.isNotEmpty ?? false) ||
        (content.videoUrl?.isNotEmpty ?? false);
    final title =
        content.titulo.isEmpty ? 'Conteúdo ${content.id}' : content.titulo;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundIce,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color:
                        isPdf
                            ? AppColors.accentOrange.withValues(alpha: 0.16)
                            : AppColors.primaryTeal.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isPdf
                        ? PhosphorIconsRegular.filePdf
                        : PhosphorIconsRegular.playCircle,
                    color:
                        isPdf ? AppColors.accentOrange : AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content.tipo.isEmpty
                            ? (isPdf ? 'PDF' : 'Vídeo')
                            : content.tipo,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed:
                        canStudy
                            ? () async {
                              if (userId != null) {
                                await ref
                                    .read(
                                      viewedContentsControllerProvider(
                                        userId!,
                                      ).notifier,
                                    )
                                    .markViewed(
                                      userId: userId!,
                                      contentId: content.id,
                                    );
                                await ref
                                    .read(
                                      lastOpenedContentControllerProvider(
                                        userId!,
                                      ).notifier,
                                    )
                                    .setLastOpened(
                                      userId: userId!,
                                      contentId: content.id,
                                    );
                              }
                              if (context.mounted) {
                                context.go(
                                  '/aluno/conteudos/estudar',
                                  extra: content,
                                );
                              }
                            }
                            : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(viewed ? 'Continuar' : 'Iniciar'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed:
                      () => context.go(
                        '/aluno/conteudos/praticar',
                        extra: content,
                      ),
                  child: const Text('Praticar'),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'PDF',
                  onPressed:
                      canOpenPdf
                          ? () {
                            context.go(
                              '/aluno/conteudos/pdf?url=${Uri.encodeComponent(content.pdfUrl!)}',
                            );
                          }
                          : null,
                  icon: const Icon(PhosphorIconsRegular.arrowSquareOut),
                ),
              ],
            ),
          ),
          if (viewed)
            Container(
              height: 3,
              decoration: const BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
