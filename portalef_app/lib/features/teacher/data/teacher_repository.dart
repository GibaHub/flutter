import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository(ref.watch(dioProvider));
});

class TeacherRepository {
  TeacherRepository(this._dio);

  final Dio _dio;

  // int? _userIdOrNull() => _ref.read(authControllerProvider).valueOrNull?.user.id;

  Future<Map<String, Object?>> getDashboard({int? groupId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/teacher/dashboard',
      queryParameters: {if (groupId != null) 'groupId': groupId},
    );
    return Map<String, Object?>.from(response.data ?? <String, dynamic>{});
  }

  Future<List<Map<String, Object?>>> listMyGroups() async {
    final response = await _dio.get<List<dynamic>>('/teacher/groups');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .toList(growable: false);
  }

  Future<List<Map<String, Object?>>> listGroupStudents(int groupId) async {
    final response = await _dio.get<List<dynamic>>(
      '/teacher/groups/$groupId/students',
    );
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .toList(growable: false);
  }

  Future<List<Map<String, Object?>>> listQuestionBanks() async {
    final response = await _dio.get<List<dynamic>>('/teacher/question-banks');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .toList(growable: false);
  }

  Future<List<Map<String, Object?>>> listTeacherEvaluations() async {
    final response = await _dio.get<List<dynamic>>('/teacher/evaluations');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .toList(growable: false);
  }
}
