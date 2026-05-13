import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/evaluation_repository.dart';

final evaluationResultProvider =
    FutureProvider.family<EvaluationResultPayload, int>((ref, evaluationId) async {
  return ref.watch(evaluationRepositoryProvider).result(evaluationId: evaluationId);
});

class EvaluationResultPage extends ConsumerWidget {
  const EvaluationResultPage({super.key, required this.evaluationId});

  final int evaluationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(evaluationResultProvider(evaluationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: asyncResult.when(
        data: (payload) {
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
                        payload.evaluation.titulo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        payload.evaluation.materia,
                        style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        payload.score == null || payload.correct == null || payload.total == null
                            ? '—'
                            : 'Score: ${payload.score} • ${payload.correct}/${payload.total}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final q in payload.questions)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.enunciado,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        for (var i = 0; i < q.opcoes.length; i += 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _OptionRow(
                              text: q.opcoes[i],
                              isSelected: q.selectedOption == i,
                              isCorrect: q.respostaCorreta == i,
                            ),
                          ),
                        if (q.explicacao?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 10),
                          Text(
                            q.explicacao!.trim(),
                            style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.75)),
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
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
  });

  final String text;
  final bool isSelected;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? AppColors.success
        : (isSelected ? AppColors.error : AppColors.darkBg.withValues(alpha: 0.6));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCorrect ? Icons.check_circle_outline : (isSelected ? Icons.cancel_outlined : Icons.circle_outlined),
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

