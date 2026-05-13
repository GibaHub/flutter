import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/multipart.dart';
import '../../auth/presentation/auth_controller.dart';

final essayRepositoryProvider = Provider<EssayRepository>((ref) {
  return EssayRepository(ref.watch(dioProvider), ref);
});

class EssayRepository {
  EssayRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  int? _userIdOrNull() => _ref.read(authControllerProvider).valueOrNull?.user.id;

  Future<List<StudentEssayListItem>> list() async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<List<dynamic>>(
      '/student/essays',
      queryParameters: {'userId': userId},
    );

    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(StudentEssayListItem.fromJson)
        .toList(growable: false);
  }

  Future<StudentEssayDetail> getDetail({required int essayId}) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final response = await _dio.get<Map<String, dynamic>>(
      '/student/essays/$essayId',
      queryParameters: {'userId': userId},
    );

    final raw = response.data ?? <String, dynamic>{};
    return StudentEssayDetail.fromJson(Map<String, Object?>.from(raw));
  }

  Future<void> submit({
    required int essayId,
    required String essayText,
    PlatformFileDraft? draft,
  }) async {
    final userId = _userIdOrNull();
    if (userId == null) throw StateError('Sessão inválida');

    final form = FormData.fromMap({
      'userId': userId,
      'essayText': essayText,
    });

    if (draft != null) {
      form.files.add(
        MapEntry(
          'draft',
          await Multipart.fromPlatformFile(draft.file),
        ),
      );
    }

    await _dio.post<void>(
      '/student/essays/$essayId/submit',
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

class StudentEssayListItem {
  const StudentEssayListItem({
    required this.essayId,
    required this.tema,
    required this.dueAt,
    required this.status,
    required this.canSubmit,
    required this.expired,
    required this.score,
  });

  final int essayId;
  final String tema;
  final DateTime? dueAt;
  final String status;
  final bool canSubmit;
  final bool expired;
  final double? score;

  factory StudentEssayListItem.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    final dueAt = dueRaw == null ? null : DateTime.tryParse(dueRaw);
    final scoreRaw = json['score'];
    final score = scoreRaw == null ? null : double.tryParse(scoreRaw.toString());

    return StudentEssayListItem(
      essayId: (json['essay_id'] as num).toInt(),
      tema: (json['tema'] as String?) ?? '',
      dueAt: dueAt,
      status: (json['status'] as String?) ?? '',
      canSubmit: (json['can_submit'] as bool?) ?? false,
      expired: (json['expired'] as bool?) ?? false,
      score: score,
    );
  }
}

class StudentEssayDetail {
  const StudentEssayDetail({
    required this.essay,
    required this.assignment,
    required this.canSubmit,
    required this.expired,
  });

  final EssayInfo essay;
  final EssayAssignment assignment;
  final bool canSubmit;
  final bool expired;

  factory StudentEssayDetail.fromJson(Map<String, Object?> json) {
    return StudentEssayDetail(
      essay: EssayInfo.fromJson(Map<String, Object?>.from((json['essay'] as Map?) ?? const {})),
      assignment: EssayAssignment.fromJson(
        Map<String, Object?>.from((json['assignment'] as Map?) ?? const {}),
      ),
      canSubmit: (json['can_submit'] as bool?) ?? false,
      expired: (json['expired'] as bool?) ?? false,
    );
  }
}

class EssayInfo {
  const EssayInfo({required this.id, required this.tema, required this.dueAt});

  final int id;
  final String tema;
  final DateTime? dueAt;

  factory EssayInfo.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    return EssayInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tema: (json['tema'] as String?) ?? '',
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
    );
  }
}

class EssayAssignment {
  const EssayAssignment({
    required this.status,
    required this.submittedAt,
    required this.gradedAt,
    required this.score,
    required this.feedback,
    required this.essayText,
    required this.draft,
  });

  final String status;
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final double? score;
  final String? feedback;
  final String? essayText;
  final EssayDraft? draft;

  factory EssayAssignment.fromJson(Map<String, Object?> json) {
    final submittedRaw = json['submitted_at'] as String?;
    final gradedRaw = json['graded_at'] as String?;
    final scoreRaw = json['score'];

    final draftRaw = json['draft'];
    EssayDraft? draft;
    if (draftRaw is Map) {
      draft = EssayDraft.fromJson(Map<String, Object?>.from(draftRaw));
    }

    return EssayAssignment(
      status: (json['status'] as String?) ?? '',
      submittedAt: submittedRaw == null ? null : DateTime.tryParse(submittedRaw),
      gradedAt: gradedRaw == null ? null : DateTime.tryParse(gradedRaw),
      score: scoreRaw == null ? null : double.tryParse(scoreRaw.toString()),
      feedback: json['feedback'] as String?,
      essayText: json['essay_text'] as String?,
      draft: draft,
    );
  }
}

class EssayDraft {
  const EssayDraft({
    required this.filename,
    required this.originalName,
    required this.mimetype,
    required this.url,
  });

  final String filename;
  final String originalName;
  final String mimetype;
  final String url;

  factory EssayDraft.fromJson(Map<String, Object?> json) {
    final rawUrl = (json['url'] as String?) ?? '';
    return EssayDraft(
      filename: (json['filename'] as String?) ?? '',
      originalName: (json['originalName'] as String?) ?? '',
      mimetype: (json['mimetype'] as String?) ?? '',
      url: rawUrl.isEmpty ? '' : EssayRepository.absoluteUploadsUrl(rawUrl),
    );
  }
}

class PlatformFileDraft {
  const PlatformFileDraft(this.file);

  final PlatformFile file;
}
