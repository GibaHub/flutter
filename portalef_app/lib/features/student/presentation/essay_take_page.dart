import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../data/essay_repository.dart';
import 'student_essays_page.dart';

final essayDetailProvider = FutureProvider.family<StudentEssayDetail, int>((
  ref,
  essayId,
) async {
  return ref.watch(essayRepositoryProvider).getDetail(essayId: essayId);
});

class EssayTakePage extends ConsumerStatefulWidget {
  const EssayTakePage({super.key, required this.essayId});

  final int essayId;

  @override
  ConsumerState<EssayTakePage> createState() => _EssayTakePageState();
}

class _EssayTakePageState extends ConsumerState<EssayTakePage> {
  final _controller = TextEditingController();
  PlatformFile? _draft;
  var _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(essayDetailProvider(widget.essayId));

    return Scaffold(
      appBar: AppBar(title: const Text('Redação')),
      body: asyncDetail.when(
        data: (data) {
          if (_controller.text.isEmpty &&
              (data.assignment.essayText?.isNotEmpty ?? false)) {
            _controller.text = data.assignment.essayText!;
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
                        data.essay.tema.isEmpty ? 'Tema' : data.essay.tema,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (data.essay.dueAt != null)
                            'Prazo: ${_formatDate(data.essay.dueAt!)}',
                          'Status: ${data.assignment.status}',
                          if (data.assignment.score != null)
                            'Nota: ${data.assignment.score}',
                        ].join(' • '),
                        style: TextStyle(
                          color: AppColors.darkBg.withValues(alpha: 0.7),
                        ),
                      ),
                      if ((data.assignment.feedback?.trim().isNotEmpty ??
                          false)) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Feedback',
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(data.assignment.feedback!.trim()),
                      ],
                      if (data.assignment.draft?.url.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            final uri = Uri.tryParse(
                              data.assignment.draft!.url,
                            );
                            if (uri == null) return;
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.attach_file),
                          label: Text(
                            data.assignment.draft!.originalName.isEmpty
                                ? 'Abrir rascunho'
                                : data.assignment.draft!.originalName,
                          ),
                        ),
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
                        'Texto da redação',
                        style: TextStyle(
                          color: AppColors.darkBg.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _controller,
                        minLines: 10,
                        maxLines: 20,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua redação aqui...',
                        ),
                        enabled: data.canSubmit && !_saving,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed:
                            !data.canSubmit || _saving
                                ? null
                                : () async {
                                  final picked = await FilePicker.platform
                                      .pickFiles(
                                        allowMultiple: false,
                                        withData: true,
                                      );
                                  final file =
                                      (picked?.files.isNotEmpty ?? false)
                                          ? picked!.files.first
                                          : null;
                                  if (file == null) return;
                                  setState(() {
                                    _draft = file;
                                  });
                                },
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          _draft == null
                              ? 'Anexar rascunho (opcional)'
                              : 'Anexo: ${_draft!.name}',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed:
                            !data.canSubmit || _saving
                                ? null
                                : () async {
                                  final text = _controller.text.trim();
                                  if (text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'O texto da redação é obrigatório',
                                        ),
                                        backgroundColor: AppColors.warning,
                                      ),
                                    );
                                    return;
                                  }
                                  await _submit(text);
                                },
                        child:
                            _saving
                                ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Enviar redação'),
                      ),
                      if (!data.canSubmit) ...[
                        const SizedBox(height: 10),
                        Text(
                          data.expired
                              ? 'Prazo encerrado.'
                              : 'Envio indisponível para este status.',
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.65),
                          ),
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

  Future<void> _submit(String essayText) async {
    setState(() {
      _saving = true;
    });
    try {
      await ref
          .read(essayRepositoryProvider)
          .submit(
            essayId: widget.essayId,
            essayText: essayText,
            draft: _draft == null ? null : PlatformFileDraft(_draft!),
          );
      ref.invalidate(essayDetailProvider(widget.essayId));
      ref.invalidate(studentEssaysProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Redação enviada com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao enviar: $e'),
            backgroundColor: AppColors.error,
          ),
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
