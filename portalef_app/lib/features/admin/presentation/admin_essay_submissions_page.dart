import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../data/admin_repository.dart';
import 'admin_scaffold.dart';

final adminEssaySubmissionsProvider =
    FutureProvider.family<List<AdminEssaySubmission>, int>((
      ref,
      essayId,
    ) async {
      return ref
          .watch(adminRepositoryProvider)
          .listEssaySubmissions(essayId: essayId);
    });

class AdminEssaySubmissionsPage extends ConsumerWidget {
  const AdminEssaySubmissionsPage({super.key, required this.essayId});

  final int essayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminEssaySubmissionsProvider(essayId));

    return AdminScaffold(
      selectedIndex: 1,
      title: 'Correção',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminEssaySubmissionsProvider(essayId));
          await ref.read(adminEssaySubmissionsProvider(essayId).future);
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
                      child: Text('Nenhuma submissão encontrada.'),
                    ),
                  ),
                ],
              );
            }

            final tema = items.first.essay.tema;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tema',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(tema.isEmpty ? '—' : tema),
                        ],
                      ),
                    ),
                  );
                }

                final s = items[index - 1];
                final status = s.status.toUpperCase();
                final canGrade = status != 'PENDENTE';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.studentName.isEmpty
                                    ? 'Aluno #${s.studentId}'
                                    : s.studentName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _StatusChip(status: s.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.studentEmail,
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if ((s.essayText?.trim().isNotEmpty ?? false))
                          Text(
                            s.essayText!.trim(),
                            style: TextStyle(
                              color: AppColors.darkBg.withValues(alpha: 0.9),
                            ),
                          )
                        else
                          Text(
                            'Sem texto',
                            style: TextStyle(
                              color: AppColors.darkBg.withValues(alpha: 0.7),
                            ),
                          ),
                        if (s.draft?.url.isNotEmpty == true) ...[
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              final absolute = _absoluteUrl(s.draft!.url);
                              final mimetype =
                                  s.draft?.mimetype.toLowerCase() ?? '';
                              final name =
                                  s.draft?.originalName.toLowerCase() ?? '';
                              final isPdf =
                                  mimetype.contains('pdf') ||
                                  name.endsWith('.pdf');

                              if (isPdf) {
                                context.go(
                                  '/pdf?url=${Uri.encodeComponent(absolute)}',
                                );
                                return;
                              }

                              final uri = Uri.tryParse(absolute);
                              if (uri == null) return;
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            icon: const Icon(Icons.attach_file),
                            label: Text(
                              s.draft!.originalName.isEmpty
                                  ? 'Abrir rascunho'
                                  : s.draft!.originalName,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    canGrade
                                        ? () async {
                                          await _openGradeDialog(
                                            context,
                                            ref,
                                            s,
                                          );
                                        }
                                        : null,
                                child: Text(
                                  s.score == null ? 'Corrigir' : 'Revisar',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (s.score != null ||
                            (s.feedback?.trim().isNotEmpty ?? false)) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Nota: ${s.score ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          if (s.feedback?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text(
                              s.feedback!.trim(),
                              style: TextStyle(
                                color: AppColors.darkBg.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
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
                    child: Text('Erro ao carregar submissões: $error'),
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

  Future<void> _openGradeDialog(
    BuildContext context,
    WidgetRef ref,
    AdminEssaySubmission submission,
  ) async {
    final scoreController = TextEditingController(
      text: submission.score?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Corrigir redação'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: scoreController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nota (0-10)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feedbackController,
                      minLines: 3,
                      maxLines: 8,
                      decoration: const InputDecoration(labelText: 'Feedback'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed:
                      saving
                          ? null
                          : () async {
                            setState(() => saving = true);
                            try {
                              final scoreText = scoreController.text.trim();
                              final score =
                                  scoreText.isEmpty
                                      ? null
                                      : double.tryParse(scoreText);
                              final feedback =
                                  feedbackController.text.trim().isEmpty
                                      ? null
                                      : feedbackController.text.trim();

                              await ref
                                  .read(adminRepositoryProvider)
                                  .gradeEssay(
                                    essayId: submission.essay.id,
                                    studentId: submission.studentId,
                                    score: score,
                                    feedback: feedback,
                                  );

                              ref.invalidate(
                                adminEssaySubmissionsProvider(essayId),
                              );
                              if (ctx.mounted) Navigator.of(ctx).pop();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Falha ao salvar: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                              setState(() => saving = false);
                            }
                          },
                  child:
                      saving
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    scoreController.dispose();
    feedbackController.dispose();
  }

  String _absoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = ApiConfig.publicBaseUrl();
    if (url.startsWith('/')) return '$base$url';
    return '$base/$url';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    final (bg, fg) = switch (s) {
      'CORRIGIDA' => (
        AppColors.success.withValues(alpha: 0.16),
        AppColors.success,
      ),
      'ENVIADA' => (
        AppColors.warning.withValues(alpha: 0.16),
        AppColors.warning,
      ),
      _ => (AppColors.darkBg.withValues(alpha: 0.08), AppColors.darkBg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
