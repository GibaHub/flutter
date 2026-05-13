import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/multipart.dart';
import '../../auth/presentation/auth_controller.dart';

final extraActivityRepositoryProvider = Provider<ExtraActivityRepository>((
  ref,
) {
  return ExtraActivityRepository(ref.watch(dioProvider), ref);
});

class ExtraActivityRepository {
  ExtraActivityRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  int? _userIdOrNull() =>
      _ref.read(authControllerProvider).valueOrNull?.user.id;

  Future<List<StudentExtraActivityListItem>> list() async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/student/extra-activities',
      queryParameters: {'userId': userId},
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(StudentExtraActivityListItem.fromJson)
        .toList(growable: false);
  }

  Future<StudentExtraActivityDetail> getDetail({
    required int activityId,
  }) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<Map<String, dynamic>>(
      '/student/extra-activities/$activityId',
      queryParameters: {'userId': userId},
    );

    final raw = response.data ?? <String, dynamic>{};
    return StudentExtraActivityDetail.fromJson(Map<String, Object?>.from(raw));
  }

  Future<void> submit({
    required int activityId,
    required String studentText,
    String? studentComment,
    List<PlatformFile> files = const [],
  }) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final form = FormData.fromMap({
      'userId': userId,
      'studentText': studentText,
      'studentComment': studentComment,
    });

    for (final f in files) {
      form.files.add(MapEntry('files', await Multipart.fromPlatformFile(f)));
    }

    await _dio.post<void>(
      '/student/extra-activities/$activityId/submit',
      data: form,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  static String absoluteUploadsUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiConfig.publicBaseUrl()}$url';
    return '${ApiConfig.publicBaseUrl()}/$url';
  }
}

class StudentExtraActivityListItem {
  const StudentExtraActivityListItem({
    required this.activityId,
    required this.titulo,
    required this.dueAt,
    required this.status,
    required this.score,
  });

  final int activityId;
  final String titulo;
  final DateTime? dueAt;
  final String status;
  final double? score;

  factory StudentExtraActivityListItem.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    final scoreRaw = json['score'];
    return StudentExtraActivityListItem(
      activityId: (json['activity_id'] as num).toInt(),
      titulo: (json['titulo'] as String?) ?? '',
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
      status: (json['status'] as String?) ?? '',
      score: scoreRaw == null ? null : double.tryParse(scoreRaw.toString()),
    );
  }
}

class StudentExtraActivityDetail {
  const StudentExtraActivityDetail({
    required this.activity,
    required this.assignment,
    required this.canSubmit,
    required this.expired,
  });

  final ExtraActivityInfo activity;
  final ExtraActivityAssignment assignment;
  final bool canSubmit;
  final bool expired;

  factory StudentExtraActivityDetail.fromJson(Map<String, Object?> json) {
    return StudentExtraActivityDetail(
      activity: ExtraActivityInfo.fromJson(
        Map<String, Object?>.from((json['activity'] as Map?) ?? const {}),
      ),
      assignment: ExtraActivityAssignment.fromJson(
        Map<String, Object?>.from((json['assignment'] as Map?) ?? const {}),
      ),
      canSubmit: (json['can_submit'] as bool?) ?? false,
      expired: (json['expired'] as bool?) ?? false,
    );
  }
}

class ExtraActivityInfo {
  const ExtraActivityInfo({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dueAt,
    required this.attachments,
  });

  final int id;
  final String titulo;
  final String? descricao;
  final DateTime? dueAt;
  final List<ActivityFile> attachments;

  factory ExtraActivityInfo.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    final attachmentsRaw = (json['attachments'] as List?) ?? const [];
    final attachments = attachmentsRaw
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(ActivityFile.fromJson)
        .toList(growable: false);

    return ExtraActivityInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: (json['titulo'] as String?) ?? '',
      descricao: json['descricao'] as String?,
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
      attachments: attachments,
    );
  }
}

class ExtraActivityAssignment {
  const ExtraActivityAssignment({
    required this.status,
    required this.submittedAt,
    required this.gradedAt,
    required this.score,
    required this.feedback,
    required this.studentText,
    required this.studentComment,
    required this.submissionFiles,
  });

  final String status;
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final double? score;
  final String? feedback;
  final String? studentText;
  final String? studentComment;
  final List<ActivityFile> submissionFiles;

  factory ExtraActivityAssignment.fromJson(Map<String, Object?> json) {
    final submittedRaw = json['submitted_at'] as String?;
    final gradedRaw = json['graded_at'] as String?;
    final scoreRaw = json['score'];
    final filesRaw = (json['submission_files'] as List?) ?? const [];
    final files = filesRaw
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(ActivityFile.fromJson)
        .toList(growable: false);

    return ExtraActivityAssignment(
      status: (json['status'] as String?) ?? '',
      submittedAt:
          submittedRaw == null ? null : DateTime.tryParse(submittedRaw),
      gradedAt: gradedRaw == null ? null : DateTime.tryParse(gradedRaw),
      score: scoreRaw == null ? null : double.tryParse(scoreRaw.toString()),
      feedback: json['feedback'] as String?,
      studentText: json['student_text'] as String?,
      studentComment: json['student_comment'] as String?,
      submissionFiles: files,
    );
  }
}

class ActivityFile {
  const ActivityFile({
    required this.id,
    required this.filename,
    required this.originalName,
    required this.mimetype,
    required this.url,
  });

  final int id;
  final String filename;
  final String originalName;
  final String mimetype;
  final String url;

  factory ActivityFile.fromJson(Map<String, Object?> json) {
    final rawUrl = (json['url'] as String?) ?? '';
    return ActivityFile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      filename: (json['filename'] as String?) ?? '',
      originalName: (json['originalName'] as String?) ?? '',
      mimetype: (json['mimetype'] as String?) ?? '',
      url:
          rawUrl.isEmpty
              ? ''
              : ExtraActivityRepository.absoluteUploadsUrl(rawUrl),
    );
  }
}
