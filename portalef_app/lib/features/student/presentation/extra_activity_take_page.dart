import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../data/extra_activity_repository.dart';
import 'student_extra_activities_page.dart';

final extraActivityDetailProvider =
    FutureProvider.family<StudentExtraActivityDetail, int>((ref, activityId) async {
  return ref.watch(extraActivityRepositoryProvider).getDetail(activityId: activityId);
});

class ExtraActivityTakePage extends ConsumerStatefulWidget {
  const ExtraActivityTakePage({super.key, required this.activityId});

  final int activityId;

  @override
  ConsumerState<ExtraActivityTakePage> createState() => _ExtraActivityTakePageState();
}

class _ExtraActivityTakePageState extends ConsumerState<ExtraActivityTakePage> {
  final _textController = TextEditingController();
  final _commentController = TextEditingController();
  List<PlatformFile> _files = const [];
  var _saving = false;

  @override
  void dispose() {
    _textController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(extraActivityDetailProvider(widget.activityId));

    return Scaffold(
      appBar: AppBar(title: const Text('Atividade Extra')),
      body: asyncDetail.when(
        data: (data) {
          if (_textController.text.isEmpty && (data.assignment.studentText?.isNotEmpty ?? false)) {
            _textController.text = data.assignment.studentText!;
          }
          if (_commentController.text.isEmpty && (data.assignment.studentComment?.isNotEmpty ?? false)) {
            _commentController.text = data.assignment.studentComment!;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.activity.titulo.isEmpty ? 'Atividade' : data.activity.titulo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (data.activity.dueAt != null) 'Prazo: ${_formatDate(data.activity.dueAt!)}',
                          'Status: ${data.assignment.status}',
                          if (data.assignment.score != null) 'Nota: ${data.assignment.score}',
                        ].join(' • '),
                        style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7)),
                      ),
                      if (data.activity.descricao?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Text(data.activity.descricao!.trim()),
                      ],
                      if (data.activity.attachments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Anexos do professor',
                          style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        for (final f in data.activity.attachments)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FilledButton.tonalIcon(
                              onPressed: () async {
                                final uri = Uri.tryParse(f.url);
                                if (uri == null) return;
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              },
                              icon: const Icon(Icons.attach_file),
                              label: Text(f.originalName.isEmpty ? f.filename : f.originalName),
                            ),
                          ),
                      ],
                      if (data.assignment.submissionFiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Seus anexos',
                          style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        for (final f in data.assignment.submissionFiles)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FilledButton.tonalIcon(
                              onPressed: () async {
                                final uri = Uri.tryParse(f.url);
                                if (uri == null) return;
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              },
                              icon: const Icon(Icons.file_present_outlined),
                              label: Text(f.originalName.isEmpty ? f.filename : f.originalName),
                            ),
                          ),
                      ],
                      if (data.assignment.feedback?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Feedback',
                          style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(data.assignment.feedback!.trim()),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Resposta (obrigatória)',
                        style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7), fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        minLines: 6,
                        maxLines: 14,
                        decoration: const InputDecoration(hintText: 'Digite sua resposta...'),
                        enabled: data.canSubmit && !_saving,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Comentário (opcional)',
                        style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7), fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _commentController,
                        minLines: 2,
                        maxLines: 6,
                        decoration: const InputDecoration(hintText: 'Observações...'),
                        enabled: data.canSubmit && !_saving,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: !data.canSubmit || _saving
                            ? null
                            : () async {
                                final picked = await FilePicker.platform.pickFiles(
                                  allowMultiple: true,
                                  withData: true,
                                );
                                final files = picked?.files ?? const <PlatformFile>[];
                                setState(() {
                                  _files = files;
                                });
                              },
                        icon: const Icon(Icons.attach_file),
                        label: Text(_files.isEmpty ? 'Anexar arquivos (opcional)' : 'Anexos: ${_files.length}'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: !data.canSubmit || _saving
                            ? null
                            : () async {
                                final text = _textController.text.trim();
                                if (text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('A resposta é obrigatória'),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                  return;
                                }
                                await _submit(text);
                              },
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Enviar atividade'),
                      ),
                      if (!data.canSubmit) ...[
                        const SizedBox(height: 10),
                        Text(
                          data.expired ? 'Prazo encerrado.' : 'Envio indisponível para este status.',
                          style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.65)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _submit(String text) async {
    setState(() {
      _saving = true;
    });
    try {
      await ref.read(extraActivityRepositoryProvider).submit(
            activityId: widget.activityId,
            studentText: text,
            studentComment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
            files: _files,
          );
      ref.invalidate(extraActivityDetailProvider(widget.activityId));
      ref.invalidate(studentExtraActivitiesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade enviada com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao enviar: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}

String _formatDate(DateTime date) {
  final d = date.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd/$mm/$yyyy';
}

