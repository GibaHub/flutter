import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/storage/last_opened_content_controller.dart';
import '../../../core/storage/viewed_contents_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/evaluation_repository.dart';
import '../data/student_repository.dart';
import '../domain/progress_summary.dart';
import '../domain/study_group.dart';

final studentProgressProvider = FutureProvider<ProgressSummary>((ref) async {
  return ref.watch(studentRepositoryProvider).getProgress();
});

final studentHomeGroupsProvider = FutureProvider<List<StudyGroup>>((ref) async {
  return ref.watch(studentRepositoryProvider).getMyGroups();
});

final pendingEvaluationsCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(evaluationRepositoryProvider).list();
  return list.where((e) => e.status.toUpperCase() != 'CONCLUIDA').length;
});

class StudentHomePage extends ConsumerWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final progress = ref.watch(studentProgressProvider);
    final groups = ref.watch(studentHomeGroupsProvider);
    final pending = ref.watch(pendingEvaluationsCountProvider);
    final viewedAsync =
        session == null
            ? const AsyncValue.data(<int>{})
            : ref.watch(viewedContentsControllerProvider(session.user.id));
    final lastOpenedAsync =
        session == null
            ? const AsyncValue.data(null)
            : ref.watch(lastOpenedContentControllerProvider(session.user.id));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(PhosphorIconsRegular.signOut),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentProgressProvider);
          ref.invalidate(studentHomeGroupsProvider);
          ref.invalidate(pendingEvaluationsCountProvider);
          final userId = ref.read(authControllerProvider).valueOrNull?.user.id;
          if (userId != null) {
            ref.invalidate(viewedContentsControllerProvider(userId));
          }
          await ref.read(studentProgressProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _WelcomeHeader(name: session?.user.name ?? ''),
                  const SizedBox(height: 16),
                  _StatsGrid(progress: progress, pending: pending),
                  const SizedBox(height: 16),
                  _ContinueFromLastCard(
                    groups: groups,
                    viewedAsync: viewedAsync,
                    lastOpenedAsync: lastOpenedAsync,
                    userId: session?.user.id,
                  ),
                  const SizedBox(height: 18),
                  _RoomsSection(groups: groups, viewedAsync: viewedAsync),
                  const SizedBox(height: 18),
                  _StudyTrackSection(
                    groups: groups,
                    viewedAsync: viewedAsync,
                    userId: session?.user.id,
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'Aluno' : name.trim();
    final initials =
        displayName
            .split(' ')
            .where((p) => p.trim().isNotEmpty)
            .take(2)
            .map((p) => p.trim()[0].toUpperCase())
            .join();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $displayName',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pronto para os estudos de hoje?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.12),
          foregroundColor: AppColors.primaryTeal,
          child: Text(
            initials.isEmpty ? 'A' : initials,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.progress, required this.pending});

  final AsyncValue<ProgressSummary> progress;
  final AsyncValue<int> pending;

  @override
  Widget build(BuildContext context) {
    final tempoHoje = progress.valueOrNull?.tempoHoje ?? 0;
    final acertos = progress.valueOrNull?.percentAcertos ?? 0;
    final streak = progress.valueOrNull?.diasSeguidos ?? 0;
    final pendencias = pending.valueOrNull ?? 0;

    final items = [
      _StatItem(
        icon: PhosphorIconsRegular.clock,
        color: AppColors.primaryTeal,
        value: _formatDurationHM(tempoHoje),
        label: 'Tempo Hoje',
      ),
      _StatItem(
        icon: PhosphorIconsRegular.percent,
        color: AppColors.primaryTeal,
        value: '$acertos%',
        label: 'Acertos',
      ),
      _StatItem(
        icon: PhosphorIconsRegular.flame,
        color: AppColors.primaryTeal,
        value: '$streak dias',
        label: 'Streak',
      ),
      _StatItem(
        icon: PhosphorIconsRegular.calendarCheck,
        color: AppColors.primaryTeal,
        value: '$pendencias',
        label: 'Provas Pendentes',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [for (final item in items) _StatCard(item: item)],
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const Spacer(),
          Text(
            item.value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ContinueFromLastCard extends ConsumerWidget {
  const _ContinueFromLastCard({
    required this.groups,
    required this.viewedAsync,
    required this.lastOpenedAsync,
    required this.userId,
  });

  final AsyncValue<List<StudyGroup>> groups;
  final AsyncValue<Set<int>> viewedAsync;
  final AsyncValue<int?> lastOpenedAsync;
  final int? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = groups.valueOrNull ?? const <StudyGroup>[];
    final viewed = viewedAsync.valueOrNull ?? const <int>{};
    final lastOpenedId = lastOpenedAsync.valueOrNull;

    StudyGroup? chosenGroup;
    StudyContent? chosenContent;

    if (lastOpenedId != null) {
      for (final g in data) {
        final match = g.contents.where((c) => c.id == lastOpenedId);
        if (match.isNotEmpty) {
          chosenGroup = g;
          chosenContent = match.first;
          break;
        }
      }
    }

    if (chosenGroup == null) {
      for (final g in data) {
        if (g.contents.isEmpty) continue;
        chosenGroup = g;
        break;
      }
    }
    final resolvedGroup = chosenGroup;
    if (chosenContent == null && resolvedGroup != null) {
      chosenContent = resolvedGroup.contents.firstWhere(
        (c) => !viewed.contains(c.id),
        orElse: () => resolvedGroup.contents.first,
      );
    }

    final title =
        chosenContent?.titulo.isNotEmpty == true
            ? chosenContent!.titulo
            : 'Escolha um conteúdo';
    final subject =
        chosenGroup?.nome.isNotEmpty == true
            ? chosenGroup!.nome
            : 'Minha matéria';

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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continuar de onde parei',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.92)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap:
                chosenContent == null
                    ? null
                    : () async {
                      final content = chosenContent;
                      if (content == null) return;
                      if (userId != null) {
                        await ref
                            .read(
                              viewedContentsControllerProvider(
                                userId!,
                              ).notifier,
                            )
                            .markViewed(userId: userId!, contentId: content.id);
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
                        context.go('/aluno/conteudos/estudar', extra: content);
                      }
                    },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsFill.play, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomsSection extends StatelessWidget {
  const _RoomsSection({required this.groups, required this.viewedAsync});

  final AsyncValue<List<StudyGroup>> groups;
  final AsyncValue<Set<int>> viewedAsync;

  @override
  Widget build(BuildContext context) {
    return groups.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final viewed = viewedAsync.valueOrNull ?? const <int>{};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minhas Salas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final g = items[index];
                  final title = g.nome.isEmpty ? 'Sala ${g.id}' : g.nome;
                  final newCount =
                      g.contents.where((c) => !viewed.contains(c.id)).length;

                  return InkWell(
                    onTap: () => context.go('/aluno/conteudos'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 140,
                      decoration: _cardDecoration(),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              PhosphorIconsRegular.chalkboardTeacher,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          Text(
                            '$newCount novos conteúdos',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 170),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StudyTrackSection extends ConsumerWidget {
  const _StudyTrackSection({
    required this.groups,
    required this.viewedAsync,
    required this.userId,
  });

  final AsyncValue<List<StudyGroup>> groups;
  final AsyncValue<Set<int>> viewedAsync;
  final int? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = groups.valueOrNull ?? const <StudyGroup>[];
    final viewed = viewedAsync.valueOrNull ?? const <int>{};
    final filtered = list
        .where((g) => g.contents.isNotEmpty)
        .toList(growable: false);

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trilha de Estudo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        for (final group in filtered.take(2)) ...[
          Text(
            group.nome.isEmpty ? 'Matéria' : group.nome,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final content in group.contents.take(4)) ...[
            _TrackCard(
              content: content,
              viewed: viewed.contains(content.id),
              onTap: () async {
                if (userId != null) {
                  await ref
                      .read(viewedContentsControllerProvider(userId!).notifier)
                      .markViewed(userId: userId!, contentId: content.id);
                }
                if (context.mounted) {
                  context.go('/aluno/conteudos/estudar', extra: content);
                }
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.content,
    required this.viewed,
    required this.onTap,
  });

  final StudyContent content;
  final bool viewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPdf =
        content.tipo.toUpperCase() == 'PDF' ||
        (content.pdfUrl?.isNotEmpty ?? false);
    final icon =
        isPdf ? PhosphorIconsRegular.filePdf : PhosphorIconsRegular.playCircle;
    final title =
        content.titulo.isEmpty ? 'Conteúdo ${content.id}' : content.titulo;
    final stripeColor = viewed ? AppColors.success : AppColors.primaryTeal;

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
        child: Row(
          children: [
            Container(
              width: 6,
              height: 64,
              decoration: BoxDecoration(
                color: stripeColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: stripeColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color:
                      viewed ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

String _formatDurationHM(int seconds) {
  final totalMinutes = (seconds / 60).floor();
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours <= 0) return '0h:${minutes.toString().padLeft(2, '0')}m';
  return '${hours}h:${minutes.toString().padLeft(2, '0')}m';
}
