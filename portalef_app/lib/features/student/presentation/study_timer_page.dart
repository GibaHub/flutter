import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/student_repository.dart';
import 'study_timer_controller.dart';

class StudyTimerPage extends ConsumerWidget {
  const StudyTimerPage({super.key, required this.contentId});

  final int? contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(studyTimerProvider);
    final notifier = ref.read(studyTimerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Cronómetro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tempo de estudo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _format(timer.elapsedSeconds),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      contentId == null ? 'Conteúdo: não informado' : 'Conteúdo: #$contentId',
                      style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: timer.isRunning ? null : notifier.start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: timer.isRunning
                        ? () async {
                            notifier.stop();
                            await _syncProgressIfPossible(context, ref);
                          }
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Parar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: timer.elapsedSeconds == 0 ? null : notifier.reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Zerar'),
            ),
            const SizedBox(height: 12),
            Text(
              'Ao parar, o app tenta sincronizar o tempo com /api/student/progress.',
              style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.65)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncProgressIfPossible(BuildContext context, WidgetRef ref) async {
    if (contentId == null) return;
    final seconds = ref.read(studyTimerProvider).elapsedSeconds;
    if (seconds <= 0) return;

    try {
      await ref.read(studentRepositoryProvider).postProgress(
            contentId: contentId!,
            tempoSeconds: seconds,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progresso sincronizado')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao sincronizar: $e'),
            backgroundColor: AppColors.warning,
          ),
        );
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

