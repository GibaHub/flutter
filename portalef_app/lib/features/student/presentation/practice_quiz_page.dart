import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/student_repository.dart';

final practiceQuestionsProvider =
    FutureProvider.family<List<PracticeQuestion>, int>((ref, contentId) async {
  return ref.watch(studentRepositoryProvider).getPracticeQuestions(contentId: contentId);
});

class PracticeQuizPage extends ConsumerStatefulWidget {
  const PracticeQuizPage({super.key, required this.contentId, required this.title});

  final int contentId;
  final String title;

  @override
  ConsumerState<PracticeQuizPage> createState() => _PracticeQuizPageState();
}

class _PracticeQuizPageState extends ConsumerState<PracticeQuizPage> {
  var _current = 0;
  int? _selected;
  bool? _isCorrect;
  var _score = 0;

  @override
  Widget build(BuildContext context) {
    final asyncQuestions = ref.watch(practiceQuestionsProvider(widget.contentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Praticar')),
      body: asyncQuestions.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('Sem questões para este conteúdo.'));
          }

          final q = questions[_current];
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
                        widget.title.isEmpty ? 'Conteúdo #${widget.contentId}' : widget.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Questão ${_current + 1} de ${questions.length} • Score: $_score',
                        style: TextStyle(color: AppColors.darkBg.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        q.enunciado,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < q.opcoes.length; i += 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FilledButton.tonal(
                    onPressed: _selected != null
                        ? null
                        : () async {
                            setState(() {
                              _selected = i;
                              _isCorrect = q.respostaCorreta != null && i == q.respostaCorreta;
                              if (_isCorrect == true) _score += 1;
                            });
                            try {
                              await ref.read(studentRepositoryProvider).postProgress(
                                    contentId: widget.contentId,
                                    tempoSeconds: 0,
                                    questoes: 1,
                                    acertos: _isCorrect == true ? 1 : 0,
                                  );
                            } catch (_) {}
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      backgroundColor: _buttonColor(i),
                      foregroundColor: AppColors.darkBg,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(q.opcoes[i]),
                    ),
                  ),
                ),
              if (_selected != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _isCorrect == true ? Icons.check_circle_outline : Icons.cancel_outlined,
                          color: _isCorrect == true ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q.explicacao?.trim().isNotEmpty == true
                                ? q.explicacao!.trim()
                                : (_isCorrect == true ? 'Correto!' : 'Incorreto.'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _selected == null
                          ? null
                          : () {
                              if (_current >= questions.length - 1) {
                                Navigator.of(context).maybePop();
                                return;
                              }
                              setState(() {
                                _current += 1;
                                _selected = null;
                                _isCorrect = null;
                              });
                            },
                      child: Text(_current >= questions.length - 1 ? 'Finalizar' : 'Próxima'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text('Erro ao carregar: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Color? _buttonColor(int index) {
    if (_selected == null) return null;
    if (_selected != index) return null;
    return _isCorrect == true ? AppColors.success.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2);
  }
}

