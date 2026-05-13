import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/parent_student.dart';
import '../domain/parent_stats.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ParentRepository(dio, ref);
});

class ParentRepository {
  ParentRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  int? _guardianIdOrNull() =>
      _ref.read(authControllerProvider).valueOrNull?.user.id;

  Future<List<ParentStudent>> getStudents() async {
    final guardianId = _guardianIdOrNull();
    if (guardianId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/parent/students',
      queryParameters: {'guardianId': guardianId},
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(ParentStudent.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, Object?>> getReportCard({required int studentId}) async {
    final guardianId = _guardianIdOrNull();
    if (guardianId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<Map<String, dynamic>>(
      '/parent/report-card',
      queryParameters: {'guardianId': guardianId, 'studentId': studentId},
    );
    final raw = response.data ?? <String, dynamic>{};
    return Map<String, Object?>.from(raw);
  }

  Future<ParentStats> getStats({required int studentId}) async {
    final guardianId = _guardianIdOrNull();
    if (guardianId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<Map<String, dynamic>>(
      '/parent/stats',
      queryParameters: {'guardianId': guardianId, 'studentId': studentId},
    );
    final raw = response.data ?? <String, dynamic>{};
    return ParentStats.fromJson(Map<String, Object?>.from(raw));
  }

  Future<List<ParentEssayItem>> getEssays({required int studentId}) async {
    final guardianId = _guardianIdOrNull();
    if (guardianId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/parent/essays',
      queryParameters: {'guardianId': guardianId, 'studentId': studentId},
    );
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(ParentEssayItem.fromJson)
        .toList(growable: false);
  }

  Future<List<ParentExtraActivityItem>> getExtraActivities({
    required int studentId,
  }) async {
    final guardianId = _guardianIdOrNull();
    if (guardianId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/parent/extra-activities',
      queryParameters: {'guardianId': guardianId, 'studentId': studentId},
    );
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(ParentExtraActivityItem.fromJson)
        .toList(growable: false);
  }
}

class ParentEssayItem {
  const ParentEssayItem({
    required this.essayId,
    required this.tema,
    required this.dueAt,
    required this.status,
    required this.score,
    required this.feedback,
  });

  final int essayId;
  final String tema;
  final DateTime? dueAt;
  final String status;
  final double? score;
  final String? feedback;

  factory ParentEssayItem.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    final scoreRaw = json['score'];
    return ParentEssayItem(
      essayId: (json['essay_id'] as num).toInt(),
      tema: (json['tema'] as String?) ?? '',
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
      status: (json['status'] as String?) ?? '',
      score: scoreRaw == null ? null : double.tryParse(scoreRaw.toString()),
      feedback: json['feedback'] as String?,
    );
  }
}

class ParentExtraActivityItem {
  const ParentExtraActivityItem({
    required this.activityId,
    required this.titulo,
    required this.dueAt,
    required this.status,
    required this.score,
    required this.feedback,
  });

  final int activityId;
  final String titulo;
  final DateTime? dueAt;
  final String status;
  final double? score;
  final String? feedback;

  factory ParentExtraActivityItem.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    final scoreRaw = json['score'];
    return ParentExtraActivityItem(
      activityId: (json['activity_id'] as num).toInt(),
      titulo: (json['titulo'] as String?) ?? '',
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
      status: (json['status'] as String?) ?? '',
      score: scoreRaw == null ? null : double.tryParse(scoreRaw.toString()),
      feedback: json['feedback'] as String?,
    );
  }
}
