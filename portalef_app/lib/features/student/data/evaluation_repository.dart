import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/presentation/auth_controller.dart';

final evaluationRepositoryProvider = Provider<EvaluationRepository>((ref) {
  return EvaluationRepository(ref.watch(dioProvider), ref);
});

class EvaluationRepository {
  EvaluationRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  int? _userIdOrNull() =>
      _ref.read(authControllerProvider).valueOrNull?.user.id;

  Future<List<EvaluationSummary>> list() async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/student/evaluations',
      queryParameters: {'userId': userId},
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(EvaluationSummary.fromJson)
        .toList(growable: false);
  }

  Future<EvaluationStartPayload> start({required int evaluationId}) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.post<Map<String, dynamic>>(
      '/student/evaluations/$evaluationId/start',
      data: {'userId': userId},
    );

    final raw = response.data ?? <String, dynamic>{};
    return EvaluationStartPayload.fromJson(Map<String, Object?>.from(raw));
  }

  Future<EvaluationSubmitPayload> submit({
    required int evaluationId,
    required List<EvaluationAnswer> answers,
  }) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.post<Map<String, dynamic>>(
      '/student/evaluations/$evaluationId/submit',
      data: {
        'userId': userId,
        'answers': answers.map((a) => a.toJson()).toList(growable: false),
      },
    );

    final raw = response.data ?? <String, dynamic>{};
    return EvaluationSubmitPayload.fromJson(Map<String, Object?>.from(raw));
  }

  Future<EvaluationResultPayload> result({required int evaluationId}) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<Map<String, dynamic>>(
      '/student/evaluations/$evaluationId/result',
      queryParameters: {'userId': userId},
    );

    final raw = response.data ?? <String, dynamic>{};
    return EvaluationResultPayload.fromJson(Map<String, Object?>.from(raw));
  }

  static List<String> normalizeOptions(Object? rawOptions) {
    final options = <String>[];
    if (rawOptions is List) {
      for (final v in rawOptions) {
        options.add(v.toString());
      }
      return options;
    }
    if (rawOptions is String) {
      try {
        final decoded = jsonDecode(rawOptions);
        if (decoded is List) {
          for (final v in decoded) {
            options.add(v.toString());
          }
        }
      } catch (_) {}
    }
    return options;
  }
}

class EvaluationSummary {
  const EvaluationSummary({
    required this.evaluationId,
    required this.titulo,
    required this.materia,
    required this.serie,
    required this.scheduledAt,
    required this.status,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  final int evaluationId;
  final String titulo;
  final String materia;
  final String? serie;
  final DateTime? scheduledAt;
  final String status;
  final double? score;
  final int? correctAnswers;
  final int? totalQuestions;

  factory EvaluationSummary.fromJson(Map<String, Object?> json) {
    final scheduledRaw = json['scheduled_at'] as String?;
    final scheduledAt =
        scheduledRaw == null ? null : DateTime.tryParse(scheduledRaw);
    final scoreRaw = json['score'];
    final score =
        scoreRaw == null ? null : double.tryParse(scoreRaw.toString());

    return EvaluationSummary(
      evaluationId: (json['evaluation_id'] as num).toInt(),
      titulo: (json['titulo'] as String?) ?? '',
      materia: (json['materia'] as String?) ?? '',
      serie: json['serie'] as String?,
      scheduledAt: scheduledAt,
      status: (json['status'] as String?) ?? 'PENDENTE',
      score: score,
      correctAnswers: (json['correct_answers'] as num?)?.toInt(),
      totalQuestions: (json['total_questions'] as num?)?.toInt(),
    );
  }
}

class EvaluationStartPayload {
  const EvaluationStartPayload({
    required this.evaluation,
    required this.questions,
  });

  final EvaluationInfo evaluation;
  final List<EvaluationQuestion> questions;

  factory EvaluationStartPayload.fromJson(Map<String, Object?> json) {
    final evaluation = EvaluationInfo.fromJson(
      Map<String, Object?>.from(
        (json['evaluation'] as Map?) ?? const <String, Object?>{},
      ),
    );
    final questionsRaw = (json['questions'] as List?) ?? const [];
    final questions = questionsRaw
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(EvaluationQuestion.fromJson)
        .toList(growable: false);

    return EvaluationStartPayload(evaluation: evaluation, questions: questions);
  }
}

class EvaluationSubmitPayload {
  const EvaluationSubmitPayload({
    required this.evaluation,
    required this.score,
    required this.correct,
    required this.total,
    required this.questions,
  });

  final EvaluationInfo evaluation;
  final double score;
  final int correct;
  final int total;
  final List<EvaluationDetailedQuestion> questions;

  factory EvaluationSubmitPayload.fromJson(Map<String, Object?> json) {
    final evaluation = EvaluationInfo.fromJson(
      Map<String, Object?>.from(
        (json['evaluation'] as Map?) ?? const <String, Object?>{},
      ),
    );
    final qRaw = (json['questions'] as List?) ?? const [];
    final questions = qRaw
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(EvaluationDetailedQuestion.fromJson)
        .toList(growable: false);

    return EvaluationSubmitPayload(
      evaluation: evaluation,
      score: double.tryParse((json['score'] ?? 0).toString()) ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      questions: questions,
    );
  }
}

class EvaluationResultPayload {
  const EvaluationResultPayload({
    required this.evaluation,
    required this.score,
    required this.correct,
    required this.total,
    required this.questions,
  });

  final EvaluationInfo evaluation;
  final double? score;
  final int? correct;
  final int? total;
  final List<EvaluationResultQuestion> questions;

  factory EvaluationResultPayload.fromJson(Map<String, Object?> json) {
    final evaluation = EvaluationInfo.fromJson(
      Map<String, Object?>.from(
        (json['evaluation'] as Map?) ?? const <String, Object?>{},
      ),
    );
    final qRaw = (json['questions'] as List?) ?? const [];
    final questions = qRaw
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(EvaluationResultQuestion.fromJson)
        .toList(growable: false);

    return EvaluationResultPayload(
      evaluation: evaluation,
      score:
          json['score'] == null
              ? null
              : double.tryParse(json['score'].toString()),
      correct: (json['correct'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      questions: questions,
    );
  }
}

class EvaluationInfo {
  const EvaluationInfo({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.serie,
    required this.scheduledAt,
  });

  final int id;
  final String titulo;
  final String materia;
  final String? serie;
  final DateTime? scheduledAt;

  factory EvaluationInfo.fromJson(Map<String, Object?> json) {
    final scheduledRaw = json['scheduled_at'] as String?;
    final scheduledAt =
        scheduledRaw == null ? null : DateTime.tryParse(scheduledRaw);
    return EvaluationInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: (json['titulo'] as String?) ?? '',
      materia: (json['materia'] as String?) ?? '',
      serie: json['serie'] as String?,
      scheduledAt: scheduledAt,
    );
  }
}

class EvaluationQuestion {
  const EvaluationQuestion({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.ordem,
  });

  final int id;
  final String enunciado;
  final List<String> opcoes;
  final int ordem;

  factory EvaluationQuestion.fromJson(Map<String, Object?> json) {
    return EvaluationQuestion(
      id: (json['id'] as num).toInt(),
      enunciado: (json['enunciado'] as String?) ?? '',
      opcoes: EvaluationRepository.normalizeOptions(json['opcoes']),
      ordem: (json['ordem'] as num?)?.toInt() ?? 0,
    );
  }
}

class EvaluationDetailedQuestion {
  const EvaluationDetailedQuestion({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.selectedOption,
    required this.correctOption,
    required this.isCorrect,
    required this.explicacao,
    required this.ordem,
  });

  final int id;
  final String enunciado;
  final List<String> opcoes;
  final int? selectedOption;
  final int correctOption;
  final bool isCorrect;
  final String? explicacao;
  final int ordem;

  factory EvaluationDetailedQuestion.fromJson(Map<String, Object?> json) {
    return EvaluationDetailedQuestion(
      id: (json['id'] as num).toInt(),
      enunciado: (json['enunciado'] as String?) ?? '',
      opcoes: EvaluationRepository.normalizeOptions(json['opcoes']),
      selectedOption:
          json['selectedOption'] == null
              ? null
              : (json['selectedOption'] as num?)?.toInt(),
      correctOption: (json['correctOption'] as num?)?.toInt() ?? 0,
      isCorrect: (json['isCorrect'] as bool?) ?? false,
      explicacao: json['explicacao'] as String?,
      ordem: (json['ordem'] as num?)?.toInt() ?? 0,
    );
  }
}

class EvaluationResultQuestion {
  const EvaluationResultQuestion({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
    required this.explicacao,
    required this.ordem,
    required this.selectedOption,
    required this.isCorrect,
  });

  final int id;
  final String enunciado;
  final List<String> opcoes;
  final int? respostaCorreta;
  final String? explicacao;
  final int ordem;
  final int? selectedOption;
  final bool? isCorrect;

  factory EvaluationResultQuestion.fromJson(Map<String, Object?> json) {
    return EvaluationResultQuestion(
      id: (json['id'] as num).toInt(),
      enunciado: (json['enunciado'] as String?) ?? '',
      opcoes: EvaluationRepository.normalizeOptions(json['opcoes']),
      respostaCorreta:
          json['resposta_correta'] == null
              ? null
              : (json['resposta_correta'] as num?)?.toInt(),
      explicacao: json['explicacao'] as String?,
      ordem: (json['ordem'] as num?)?.toInt() ?? 0,
      selectedOption:
          json['selected_option'] == null
              ? null
              : (json['selected_option'] as num?)?.toInt(),
      isCorrect: json['is_correct'] as bool?,
    );
  }
}

class EvaluationAnswer {
  const EvaluationAnswer({
    required this.questionId,
    required this.selectedOption,
  });

  final int questionId;
  final int? selectedOption;

  Map<String, Object?> toJson() {
    return {'questionId': questionId, 'selectedOption': selectedOption};
  }
}
