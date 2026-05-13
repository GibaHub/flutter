import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/parent_repository.dart';
import 'parent_scaffold.dart';

final reportCardProvider = FutureProvider.family<Map<String, Object?>, int>((ref, studentId) async {
  final repo = ref.watch(parentRepositoryProvider);
  return repo.getReportCard(studentId: studentId);
});

class ReportCardPage extends ConsumerWidget {
  const ReportCardPage({super.key, required this.studentId});

  final int? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = studentId;
    if (id == null) {
      return ParentScaffold(
        selectedIndex: 0,
        title: 'Boletim',
        body: Center(
          child: Text(
            'studentId ausente',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final report = ref.watch(reportCardProvider(id));

    return ParentScaffold(
      selectedIndex: 0,
      title: 'Boletim',
      studentId: id,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reportCardProvider(id));
          await ref.read(reportCardProvider(id).future);
        },
        child: report.when(
          data: (data) {
            final mediaFinal = data['mediaFinal'];
            final subjects = (data['subjects'] as List?) ?? const [];
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SummaryCard(mediaFinal: mediaFinal),
                const SizedBox(height: 12),
                for (final s in subjects.whereType<Map>())
                  _SubjectCard(subject: Map<String, Object?>.from(s)),
              ],
            );
          },
          error: (error, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Erro ao carregar boletim: $error'),
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

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final Map<String, Object?> subject;

  @override
  Widget build(BuildContext context) {
    final materia = (subject['materia'] as String?) ?? 'Geral';
    final media = subject['media'];
    final provas = (subject['provas'] as List?) ?? const [];

    final stripe = _gradeColor(media);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 74,
                decoration: BoxDecoration(
                  color: stripe,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
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
                          PhosphorIconsRegular.bookOpen,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              materia,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              media == null ? 'Média: -' : 'Média: $media',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (provas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Divider(color: AppColors.textSecondary.withValues(alpha: 0.12), height: 1),
                  const SizedBox(height: 10),
                  for (final p in provas.whereType<Map>())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (p['titulo'] as String?) ?? 'Prova',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (p['scheduled_at'] as String?) ?? '',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            p['score'] == null ? '-' : p['score'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.mediaFinal});

  final Object? mediaFinal;

  @override
  Widget build(BuildContext context) {
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
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(PhosphorIconsRegular.medal, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Média geral',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mediaFinal == null ? '-' : mediaFinal.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _gradeColor(Object? media) {
  if (media == null) return AppColors.primaryTeal;
  final value = double.tryParse(media.toString());
  if (value == null) return AppColors.primaryTeal;
  if (value >= 7) return AppColors.success;
  if (value >= 5) return AppColors.warning;
  return AppColors.error;
}
