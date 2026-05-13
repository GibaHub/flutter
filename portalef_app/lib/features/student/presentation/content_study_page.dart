import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/storage/last_opened_content_controller.dart';
import '../../../core/storage/viewed_contents_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../data/student_repository.dart';
import '../domain/study_group.dart';
import '../../auth/presentation/auth_controller.dart';

class ContentStudyPage extends ConsumerStatefulWidget {
  const ContentStudyPage({super.key, required this.content});

  final StudyContent content;

  @override
  ConsumerState<ContentStudyPage> createState() => _ContentStudyPageState();
}

class _ContentStudyPageState extends ConsumerState<ContentStudyPage> {
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  var _elapsedSeconds = 0;
  var _syncing = false;
  var _allowPop = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final session = ref.read(authControllerProvider).valueOrNull;
      if (session == null) return;
      await ref
          .read(viewedContentsControllerProvider(session.user.id).notifier)
          .markViewed(userId: session.user.id, contentId: widget.content.id);
      await ref
          .read(lastOpenedContentControllerProvider(session.user.id).notifier)
          .setLastOpened(userId: session.user.id, contentId: widget.content.id);
    });
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds = _stopwatch.elapsed.inSeconds;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    final elapsed = _stopwatch.elapsed.inSeconds;
    if (elapsed > 0) {
      Future.microtask(() async {
        try {
          await ref
              .read(studentRepositoryProvider)
              .postProgress(
                contentId: widget.content.id,
                tempoSeconds: elapsed,
              );
        } catch (_) {}
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final pdfUrl = content.pdfUrl;
    final videoUrl = content.videoUrl;

    return PopScope(
      canPop: _allowPop && !_syncing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_syncing) return;
        final navigator = Navigator.of(context);
        Future.microtask(() async {
          await _syncProgress();
          if (!mounted) return;
          setState(() {
            _allowPop = true;
          });
          if (mounted) {
            navigator.pop(result);
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            content.titulo.isEmpty ? 'Conteúdo #${content.id}' : content.titulo,
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _format(_elapsedSeconds),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Finalizar',
              onPressed:
                  _syncing
                      ? null
                      : () async {
                        await _syncProgress();
                        if (!mounted) return;
                        setState(() {
                          _allowPop = true;
                        });
                        if (context.mounted) Navigator.of(context).pop();
                      },
              icon:
                  _syncing
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check),
            ),
          ],
        ),
        body: Column(
          children: [
            if (videoUrl != null && videoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: FilledButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(videoUrl);
                    if (uri == null) return;
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Abrir vídeo'),
                ),
              ),
            Expanded(
              child:
                  (pdfUrl == null || pdfUrl.isEmpty)
                      ? Center(
                        child: Text(
                          'Nenhum PDF disponível',
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                      : SfPdfViewer.network(pdfUrl),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncProgress() async {
    if (_syncing) return;
    final elapsed = _stopwatch.elapsed.inSeconds;
    if (elapsed <= 0) return;

    setState(() {
      _syncing = true;
    });

    try {
      await ref
          .read(studentRepositoryProvider)
          .postProgress(contentId: widget.content.id, tempoSeconds: elapsed);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao sincronizar: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }

  String _format(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
