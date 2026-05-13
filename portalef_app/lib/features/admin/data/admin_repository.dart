import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/multipart.dart';
import '../../../core/network/dio_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(dioProvider));
});

class AdminRepository {
  AdminRepository(this._dio);

  final Dio _dio;

  Future<AdminStats> getStats() async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/stats');
    final raw = response.data ?? <String, dynamic>{};
    return AdminStats.fromJson(Map<String, Object?>.from(raw));
  }

  Future<List<AdminEssay>> listEssays() async {
    final response = await _dio.get<List<dynamic>>('/admin/essays');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminEssay.fromJson)
        .toList(growable: false);
  }

  Future<List<AdminEssaySubmission>> listEssaySubmissions({
    required int essayId,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/essays/$essayId/submissions',
    );
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminEssaySubmission.fromJson)
        .toList(growable: false);
  }

  Future<void> gradeEssay({
    required int essayId,
    required int studentId,
    required double? score,
    required String? feedback,
  }) async {
    await _dio.put<void>(
      '/admin/essays/$essayId/grade',
      data: {'studentId': studentId, 'score': score, 'feedback': feedback},
    );
  }

  Future<List<AdminExtraActivity>> listExtraActivities() async {
    final response = await _dio.get<List<dynamic>>('/admin/extra-activities');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminExtraActivity.fromJson)
        .toList(growable: false);
  }

  Future<List<AdminExtraActivitySubmission>> listExtraActivitySubmissions({
    required int activityId,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/extra-activities/$activityId/submissions',
    );
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminExtraActivitySubmission.fromJson)
        .toList(growable: false);
  }

  Future<void> gradeExtraActivity({
    required int activityId,
    required int studentId,
    required double? score,
    required String? feedback,
  }) async {
    await _dio.put<void>(
      '/admin/extra-activities/$activityId/grade',
      data: {'studentId': studentId, 'score': score, 'feedback': feedback},
    );
  }

  Future<List<AdminUser>> getUsers({String? cargo}) async {
    final response = await _dio.get<List<dynamic>>(
      '/users',
      queryParameters: cargo == null ? null : {'cargo': cargo},
    );
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminUser.fromJson)
        .toList(growable: false);
  }

  Future<AdminUser> createUser({
    required String nome,
    required String email,
    required String senha,
    required String cargo,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: {'nome': nome, 'email': email, 'senha': senha, 'cargo': cargo},
    );
    final raw = response.data ?? <String, dynamic>{};
    return AdminUser.fromJson(Map<String, Object?>.from(raw));
  }

  Future<AdminUser> updateUser({
    required int id,
    required String nome,
    required String email,
    required String cargo,
    String? senha,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/users/$id',
      data: {'nome': nome, 'email': email, 'cargo': cargo, 'senha': senha},
    );
    final raw = response.data ?? <String, dynamic>{};
    return AdminUser.fromJson(Map<String, Object?>.from(raw));
  }

  Future<void> deleteUser({required int id}) async {
    await _dio.delete<void>('/users/$id');
  }

  Future<List<AdminGroup>> listGroups() async {
    final response = await _dio.get<List<dynamic>>('/groups');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminGroup.fromJson)
        .toList(growable: false);
  }

  Future<AdminGroupDetails> getGroupDetails({required int id}) async {
    final response = await _dio.get<Map<String, dynamic>>('/groups/$id');
    final raw = response.data ?? <String, dynamic>{};
    return AdminGroupDetails.fromJson(Map<String, Object?>.from(raw));
  }

  Future<int> createGroup({
    required String nome,
    String? descricao,
    List<int>? contentIds,
    List<int>? studentIds,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/groups',
      data: {
        'nome': nome,
        'descricao': descricao,
        if (contentIds != null) 'contentIds': contentIds,
        if (studentIds != null) 'studentIds': studentIds,
      },
    );
    final data = Map<String, Object?>.from(
      response.data ?? <String, dynamic>{},
    );
    return (data['groupId'] as num?)?.toInt() ?? 0;
  }

  Future<AdminGroup> updateGroup({
    required int id,
    required String nome,
    String? descricao,
    List<int>? contentIds,
    List<int>? studentIds,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/groups/$id',
      data: {
        'nome': nome,
        'descricao': descricao,
        if (contentIds != null) 'contentIds': contentIds,
        if (studentIds != null) 'studentIds': studentIds,
      },
    );
    final raw = response.data ?? <String, dynamic>{};
    return AdminGroup.fromJson(Map<String, Object?>.from(raw));
  }

  Future<List<AdminStudent>> listStudents() async {
    final response = await _dio.get<List<dynamic>>('/students');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminStudent.fromJson)
        .toList(growable: false);
  }

  Future<void> deleteGroup({required int id}) async {
    await _dio.delete<void>('/groups/$id');
  }

  Future<List<AdminContent>> listContents({
    String? materia,
    String? tipo,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/contents',
      queryParameters: {
        if (materia != null) 'materia': materia,
        if (tipo != null) 'tipo': tipo,
      },
    );
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminContent.fromJson)
        .toList(growable: false);
  }

  Future<AdminContent> getContentById({required int id}) async {
    final response = await _dio.get<Map<String, dynamic>>('/contents/$id');
    final raw = response.data ?? <String, dynamic>{};
    return AdminContent.fromJson(Map<String, Object?>.from(raw));
  }

  Future<AdminContent> createContent({
    required String titulo,
    required String materia,
    required String categoria,
    String? videoUrl,
    PlatformFile? pdfFile,
  }) async {
    final form = FormData.fromMap({
      'titulo': titulo,
      'materia': materia,
      'categoria': categoria,
      'videoUrl': videoUrl,
    });

    if (pdfFile != null) {
      form.files.add(
        MapEntry('file', await Multipart.fromPlatformFile(pdfFile)),
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/contents',
      data: form,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    final raw = response.data ?? <String, dynamic>{};
    return AdminContent.fromJson(Map<String, Object?>.from(raw));
  }

  Future<AdminContent> updateContent({
    required int id,
    required String titulo,
    required String materia,
    required String categoria,
    String? videoUrl,
    PlatformFile? pdfFile,
  }) async {
    final form = FormData.fromMap({
      'titulo': titulo,
      'materia': materia,
      'categoria': categoria,
      'videoUrl': videoUrl,
    });

    if (pdfFile != null) {
      form.files.add(
        MapEntry('file', await Multipart.fromPlatformFile(pdfFile)),
      );
    }

    final response = await _dio.put<Map<String, dynamic>>(
      '/admin/contents/$id',
      data: form,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    final raw = response.data ?? <String, dynamic>{};
    return AdminContent.fromJson(Map<String, Object?>.from(raw));
  }

  Future<void> deleteContent({required int id}) async {
    await _dio.delete<void>('/admin/contents/$id');
  }

  Future<List<AdminGuardianLink>> listGuardianLinks() async {
    final response = await _dio.get<List<dynamic>>('/users/links');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((m) => Map<String, Object?>.from(m))
        .map(AdminGuardianLink.fromJson)
        .toList(growable: false);
  }

  Future<void> linkStudentToGuardian({
    required int studentId,
    required int guardianId,
  }) async {
    await _dio.post<void>(
      '/users/link',
      data: {'studentId': studentId, 'guardianId': guardianId},
    );
  }

  Future<void> deleteGuardianLink({required int id}) async {
    await _dio.delete<void>('/users/link/$id');
  }
}

class AdminStats {
  const AdminStats({
    required this.totalAlunos,
    required this.materiasAtivas,
    required this.questoesCadastradas,
  });

  final int totalAlunos;
  final int materiasAtivas;
  final int questoesCadastradas;

  factory AdminStats.fromJson(Map<String, Object?> json) {
    return AdminStats(
      totalAlunos: (json['totalAlunos'] as num?)?.toInt() ?? 0,
      materiasAtivas: (json['materiasAtivas'] as num?)?.toInt() ?? 0,
      questoesCadastradas: (json['questoesCadastradas'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminEssay {
  const AdminEssay({
    required this.id,
    required this.tema,
    required this.dueAt,
    required this.totalAlunos,
    required this.enviadas,
    required this.corrigidas,
  });

  final int id;
  final String tema;
  final DateTime? dueAt;
  final int totalAlunos;
  final int enviadas;
  final int corrigidas;

  factory AdminEssay.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    return AdminEssay(
      id: (json['id'] as num).toInt(),
      tema: (json['tema'] as String?) ?? '',
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
      totalAlunos: int.tryParse((json['total_alunos'] ?? 0).toString()) ?? 0,
      enviadas: int.tryParse((json['enviadas'] ?? 0).toString()) ?? 0,
      corrigidas: int.tryParse((json['corrigidas'] ?? 0).toString()) ?? 0,
    );
  }
}

class AdminEssaySubmission {
  const AdminEssaySubmission({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.submittedAt,
    required this.gradedAt,
    required this.score,
    required this.feedback,
    required this.essayText,
    required this.draft,
    required this.essay,
  });

  final int studentId;
  final String studentName;
  final String studentEmail;
  final String status;
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final double? score;
  final String? feedback;
  final String? essayText;
  final AdminEssayDraft? draft;
  final AdminEssayInfo essay;

  factory AdminEssaySubmission.fromJson(Map<String, Object?> json) {
    final submittedRaw = json['submitted_at'] as String?;
    final gradedRaw = json['graded_at'] as String?;
    final draftRaw = json['draft'];

    return AdminEssaySubmission(
      studentId: (json['student_id'] as num).toInt(),
      studentName: (json['student_name'] as String?) ?? '',
      studentEmail: (json['student_email'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      submittedAt:
          submittedRaw == null ? null : DateTime.tryParse(submittedRaw),
      gradedAt: gradedRaw == null ? null : DateTime.tryParse(gradedRaw),
      score:
          json['score'] == null
              ? null
              : double.tryParse(json['score'].toString()),
      feedback: json['feedback'] as String?,
      essayText: json['essay_text'] as String?,
      draft:
          draftRaw is Map
              ? AdminEssayDraft.fromJson(Map<String, Object?>.from(draftRaw))
              : null,
      essay: AdminEssayInfo.fromJson(
        Map<String, Object?>.from((json['essay'] as Map?) ?? const {}),
      ),
    );
  }
}

class AdminEssayInfo {
  const AdminEssayInfo({
    required this.id,
    required this.tema,
    required this.dueAt,
  });

  final int id;
  final String tema;
  final DateTime? dueAt;

  factory AdminEssayInfo.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    return AdminEssayInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tema: (json['tema'] as String?) ?? '',
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
    );
  }
}

class AdminEssayDraft {
  const AdminEssayDraft({
    required this.filename,
    required this.originalName,
    required this.mimetype,
    required this.url,
  });

  final String filename;
  final String originalName;
  final String mimetype;
  final String url;

  factory AdminEssayDraft.fromJson(Map<String, Object?> json) {
    return AdminEssayDraft(
      filename: (json['filename'] as String?) ?? '',
      originalName: (json['originalName'] as String?) ?? '',
      mimetype: (json['mimetype'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
    );
  }
}

class AdminExtraActivity {
  const AdminExtraActivity({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dueAt,
    required this.totalAlunos,
    required this.enviadas,
    required this.corrigidas,
  });

  final int id;
  final String titulo;
  final String? descricao;
  final DateTime? dueAt;
  final int totalAlunos;
  final int enviadas;
  final int corrigidas;

  factory AdminExtraActivity.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    return AdminExtraActivity(
      id: (json['id'] as num).toInt(),
      titulo: (json['titulo'] as String?) ?? '',
      descricao: json['descricao'] as String?,
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
      totalAlunos: int.tryParse((json['total_alunos'] ?? 0).toString()) ?? 0,
      enviadas: int.tryParse((json['enviadas'] ?? 0).toString()) ?? 0,
      corrigidas: int.tryParse((json['corrigidas'] ?? 0).toString()) ?? 0,
    );
  }
}

class AdminExtraActivitySubmission {
  const AdminExtraActivitySubmission({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.status,
    required this.submittedAt,
    required this.gradedAt,
    required this.score,
    required this.feedback,
    required this.studentText,
    required this.studentComment,
    required this.submissionFiles,
    required this.activity,
  });

  final int studentId;
  final String studentName;
  final String studentEmail;
  final String status;
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final double? score;
  final String? feedback;
  final String? studentText;
  final String? studentComment;
  final List<AdminFile> submissionFiles;
  final AdminExtraActivityInfo activity;

  factory AdminExtraActivitySubmission.fromJson(Map<String, Object?> json) {
    final submittedRaw = json['submitted_at'] as String?;
    final gradedRaw = json['graded_at'] as String?;
    final filesRaw = (json['submission_files'] as List?) ?? const [];

    return AdminExtraActivitySubmission(
      studentId: (json['student_id'] as num).toInt(),
      studentName: (json['student_name'] as String?) ?? '',
      studentEmail: (json['student_email'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      submittedAt:
          submittedRaw == null ? null : DateTime.tryParse(submittedRaw),
      gradedAt: gradedRaw == null ? null : DateTime.tryParse(gradedRaw),
      score:
          json['score'] == null
              ? null
              : double.tryParse(json['score'].toString()),
      feedback: json['feedback'] as String?,
      studentText: json['student_text'] as String?,
      studentComment: json['student_comment'] as String?,
      submissionFiles: filesRaw
          .whereType<Map>()
          .map((m) => Map<String, Object?>.from(m))
          .map(AdminFile.fromJson)
          .toList(growable: false),
      activity: AdminExtraActivityInfo.fromJson(
        Map<String, Object?>.from((json['activity'] as Map?) ?? const {}),
      ),
    );
  }
}

class AdminExtraActivityInfo {
  const AdminExtraActivityInfo({
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
  final List<AdminFile> attachments;

  factory AdminExtraActivityInfo.fromJson(Map<String, Object?> json) {
    final dueRaw = json['due_at'] as String?;
    final attachmentsRaw = (json['attachments'] as List?) ?? const [];
    return AdminExtraActivityInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: (json['titulo'] as String?) ?? '',
      descricao: json['descricao'] as String?,
      dueAt: dueRaw == null ? null : DateTime.tryParse(dueRaw),
      attachments: attachmentsRaw
          .whereType<Map>()
          .map((m) => Map<String, Object?>.from(m))
          .map(AdminFile.fromJson)
          .toList(growable: false),
    );
  }
}

class AdminFile {
  const AdminFile({
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

  factory AdminFile.fromJson(Map<String, Object?> json) {
    return AdminFile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      filename: (json['filename'] as String?) ?? '',
      originalName: (json['originalName'] as String?) ?? '',
      mimetype: (json['mimetype'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
    required this.createdAt,
  });

  final int id;
  final String nome;
  final String email;
  final String cargo;
  final DateTime? createdAt;

  factory AdminUser.fromJson(Map<String, Object?> json) {
    final createdRaw = json['created_at'] as String?;
    return AdminUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: (json['nome'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      cargo: (json['cargo'] as String?) ?? '',
      createdAt: createdRaw == null ? null : DateTime.tryParse(createdRaw),
    );
  }
}

class AdminGroup {
  const AdminGroup({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.createdAt,
  });

  final int id;
  final String nome;
  final String? descricao;
  final DateTime? createdAt;

  factory AdminGroup.fromJson(Map<String, Object?> json) {
    final createdRaw = json['created_at'] as String?;
    return AdminGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: (json['nome'] as String?) ?? '',
      descricao: json['descricao'] as String?,
      createdAt: createdRaw == null ? null : DateTime.tryParse(createdRaw),
    );
  }
}

class AdminGroupDetails extends AdminGroup {
  const AdminGroupDetails({
    required super.id,
    required super.nome,
    required super.descricao,
    required super.createdAt,
    required this.contentIds,
    required this.studentIds,
  });

  final List<int> contentIds;
  final List<int> studentIds;

  factory AdminGroupDetails.fromJson(Map<String, Object?> json) {
    final contentRaw = json['content_ids'];
    final studentRaw = json['student_ids'];

    return AdminGroupDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: (json['nome'] as String?) ?? '',
      descricao: json['descricao'] as String?,
      createdAt:
          (json['created_at'] as String?) == null
              ? null
              : DateTime.tryParse((json['created_at'] as String)),
      contentIds: _asIntList(contentRaw),
      studentIds: _asIntList(studentRaw),
    );
  }
}

class AdminContent {
  const AdminContent({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.tipo,
    required this.url,
    required this.videoUrl,
    required this.pdfUrl,
    required this.categoria,
    required this.createdAt,
  });

  final int id;
  final String titulo;
  final String materia;
  final String? tipo;
  final String? url;
  final String? videoUrl;
  final String? pdfUrl;
  final String? categoria;
  final DateTime? createdAt;

  factory AdminContent.fromJson(Map<String, Object?> json) {
    final createdRaw = json['created_at'] as String?;
    return AdminContent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: (json['titulo'] as String?) ?? '',
      materia: (json['materia'] as String?) ?? '',
      tipo: json['tipo'] as String?,
      url: json['url'] as String?,
      videoUrl: json['video_url'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      categoria: json['categoria'] as String?,
      createdAt: createdRaw == null ? null : DateTime.tryParse(createdRaw),
    );
  }
}

class AdminStudent {
  const AdminStudent({
    required this.id,
    required this.nome,
    required this.email,
  });

  final int id;
  final String nome;
  final String email;

  factory AdminStudent.fromJson(Map<String, Object?> json) {
    return AdminStudent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: (json['nome'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
    );
  }
}

class AdminGuardianLink {
  const AdminGuardianLink({
    required this.id,
    required this.studentId,
    required this.guardianId,
    required this.studentName,
    required this.guardianName,
  });

  final int id;
  final int studentId;
  final int guardianId;
  final String studentName;
  final String guardianName;

  factory AdminGuardianLink.fromJson(Map<String, Object?> json) {
    return AdminGuardianLink(
      id: (json['id'] as num?)?.toInt() ?? 0,
      studentId: (json['student_id'] as num?)?.toInt() ?? 0,
      guardianId: (json['guardian_id'] as num?)?.toInt() ?? 0,
      studentName: (json['student_name'] as String?) ?? '',
      guardianName: (json['guardian_name'] as String?) ?? '',
    );
  }
}

List<int> _asIntList(Object? value) {
  if (value is List) {
    return value
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .where((e) => e != 0)
        .toList(growable: false);
  }
  return const [];
}
