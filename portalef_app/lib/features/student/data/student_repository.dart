import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/progress_summary.dart';
import '../domain/study_group.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StudentRepository(dio, ref);
});

class StudentRepository {
  StudentRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  int? _userIdOrNull() =>
      _ref.read(authControllerProvider).valueOrNull?.user.id;

  Future<ProgressSummary> getProgress() async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<Map<String, dynamic>>(
      '/student/progress',
      queryParameters: {'userId': userId},
    );
    final raw = response.data ?? <String, dynamic>{};
    return ProgressSummary.fromJson(Map<String, Object?>.from(raw));
  }

  Future<void> postProgress({
    required int contentId,
    required int tempoSeconds,
    int acertos = 0,
    int questoes = 0,
  }) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    await _dio.post<void>(
      '/student/progress',
      data: {
        'userId': userId,
        'contentId': contentId,
        'tempo': tempoSeconds,
        'acertos': acertos,
        'questoes': questoes,
      },
    );
  }

  Future<List<StudyGroup>> getMyGroups() async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/student/my-groups',
      queryParameters: {'userId': userId},
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(StudyGroup.fromJson)
        .toList(growable: false);
  }

  Future<List<PracticeQuestion>> getPracticeQuestions({
    required int contentId,
  }) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/student/questions/$contentId',
      queryParameters: {'userId': userId},
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(PracticeQuestion.fromJson)
        .toList(growable: false);
  }
}

class PracticeQuestion {
  const PracticeQuestion({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
    required this.explicacao,
  });

  final int id;
  final String enunciado;
  final List<String> opcoes;
  final int? respostaCorreta;
  final String? explicacao;

  factory PracticeQuestion.fromJson(Map<String, Object?> json) {
    final rawOptions = json['opcoes'];
    final options = <String>[];
    if (rawOptions is List) {
      for (final v in rawOptions) {
        options.add(v.toString());
      }
    } else if (rawOptions is String) {
      try {
        final parsed = jsonDecode(rawOptions);
        if (parsed is List) {
          for (final v in parsed) {
            options.add(v.toString());
          }
        }
      } catch (_) {}
    }

    final correct = json['resposta_correta'];
    final correctIndex =
        correct == null ? null : int.tryParse(correct.toString());

    return PracticeQuestion(
      id: (json['id'] as num).toInt(),
      enunciado: (json['enunciado'] as String?) ?? '',
      opcoes: options,
      respostaCorreta: correctIndex,
      explicacao: json['explicacao'] as String?,
    );
  }
}
