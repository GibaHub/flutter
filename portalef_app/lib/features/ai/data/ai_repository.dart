import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(dioProvider));
});

class AiRepository {
  AiRepository(this._dio);

  final Dio _dio;

  Future<bool> isEnabled({int? studentId}) async {
    final res = await _dio.get(
      '/ai/status',
      queryParameters: studentId != null ? {'studentId': studentId} : null,
    );
    final data = res.data;
    if (data is Map && data['enabled'] is bool) return data['enabled'] as bool;
    return false;
  }

  Future<AiAnalyzeResponse> analyze({required String message, int? studentId}) async {
    final payload = <String, dynamic>{
      'message': message,
      if (studentId != null) 'studentId': studentId,
    };
    final res = await _dio.post('/ai/analyze', data: payload);
    return AiAnalyzeResponse.fromJson(res.data);
  }
}

class AiAnalyzeResponse {
  AiAnalyzeResponse({
    required this.reply,
    required this.suggestions,
  });

  final String reply;
  final List<AiSupportContent> suggestions;

  factory AiAnalyzeResponse.fromJson(dynamic json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final reply = (map['reply'] ?? '').toString();
    final sug = map['suggestions'];
    final list = (sug is Map ? sug['supportContents'] : null) as dynamic;
    final items =
        list is List ? list.map((e) => AiSupportContent.fromJson(e)).toList() : <AiSupportContent>[];
    return AiAnalyzeResponse(reply: reply, suggestions: items);
  }
}

class AiSupportContent {
  AiSupportContent({
    required this.id,
    required this.titulo,
    required this.materia,
    this.tipo,
    this.url,
    this.videoUrl,
    this.pdfUrl,
  });

  final int id;
  final String titulo;
  final String materia;
  final String? tipo;
  final String? url;
  final String? videoUrl;
  final String? pdfUrl;

  factory AiSupportContent.fromJson(dynamic json) {
    final map = json is Map ? json : const <String, dynamic>{};
    return AiSupportContent(
      id: (map['id'] as num?)?.toInt() ?? 0,
      titulo: (map['titulo'] ?? '').toString(),
      materia: (map['materia'] ?? '').toString(),
      tipo: map['tipo']?.toString(),
      url: map['url']?.toString(),
      videoUrl: map['video_url']?.toString(),
      pdfUrl: map['pdf_url']?.toString(),
    );
  }
}

