import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/evaluation_repository.dart';

final evaluationStartProvider =
    FutureProvider.family<EvaluationStartPayload, int>((
      ref,
      evaluationId,
    ) async {
      return ref
          .watch(evaluationRepositoryProvider)
          .start(evaluationId: evaluationId);
    });

class EvaluationTakePage extends ConsumerStatefulWidget {
  const EvaluationTakePage({super.key, required this.evaluationId});

  final int evaluationId;

  @override
  ConsumerState<EvaluationTakePage> createState() => _EvaluationTakePageState();
}

class _EvaluationTakePageState extends ConsumerState<EvaluationTakePage> {
  final Map<int, int?> _answers = {};
  var _currentIndex = 0;
  var _submitting = false;

  @override
  Widget build(BuildContext context) {
    final asyncStart = ref.watch(evaluationStartProvider(widget.evaluationId));

    return asyncStart.when(
      data: (payload) {
        final questions = payload.questions;
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Avaliação')),
            body: const Center(child: Text('Nenhuma questão encontrada.')),
          );
        }

        final current = questions[_currentIndex];
        final selected = _answers[current.id];

        return PopScope(
          canPop: !_submitting,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                payload.evaluation.titulo.isEmpty
                    ? 'Avaliação'
                    : payload.evaluation.titulo,
              ),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${_currentIndex + 1}/${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payload.evaluation.materia,
                          style: TextStyle(
                            color: AppColors.darkBg.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          current.enunciado,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < current.opcoes.length; i += 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonal(
                      onPressed:
                          _submitting
                              ? null
                              : () {
                                setState(() {
                                  _answers[current.id] = i;
                                });
                              },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        backgroundColor:
                            selected == i
                                ? AppColors.royalBlue.withValues(alpha: 0.16)
                                : null,
                        foregroundColor: AppColors.darkBg,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(current.opcoes[i]),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _submitting || _currentIndex == 0
                                ? null
                                : () {
                                  setState(() {
                                    _currentIndex -= 1;
                                  });
                                },
                        child: const Text('Anterior'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            _submitting
                                ? null
                                : () async {
                                  if (_currentIndex < questions.length - 1) {
                                    setState(() {
                                      _currentIndex += 1;
                                    });
                                    return;
                                  }

                                  await _submit(context);
                                },
                        child:
                            _submitting
                                ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _currentIndex < questions.length - 1
                                      ? 'Próxima'
                                      : 'Enviar',
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      error: (error, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Avaliação')),
          body: Center(child: Text('Erro ao iniciar: $error')),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _submitting = true;
    });
    try {
      final payload = await ref
          .read(evaluationRepositoryProvider)
          .submit(
            evaluationId: widget.evaluationId,
            answers: _answers.entries
                .map(
                  (e) => EvaluationAnswer(
                    questionId: e.key,
                    selectedOption: e.value,
                  ),
                )
                .toList(growable: false),
          );

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Resultado'),
            content: Text(
              'Score: ${payload.score} • ${payload.correct}/${payload.total}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (context.mounted) {
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
          _submitting = false;
        });
      }
    }
  }
}
