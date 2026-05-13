class StudyGroup {
  const StudyGroup({
    required this.id,
    required this.nome,
    required this.contents,
  });

  final int id;
  final String nome;
  final List<StudyContent> contents;

  factory StudyGroup.fromJson(Map<String, Object?> json) {
    final rawContents = json['contents'];
    final contents = <StudyContent>[];
    if (rawContents is List) {
      for (final item in rawContents) {
        if (item is Map) {
          contents.add(StudyContent.fromJson(Map<String, Object?>.from(item)));
        }
      }
    }

    return StudyGroup(
      id: (json['id'] as num).toInt(),
      nome: (json['nome'] as String?) ?? '',
      contents: contents,
    );
  }
}

class StudyContent {
  const StudyContent({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.pdfUrl,
    required this.videoUrl,
  });

  final int id;
  final String titulo;
  final String tipo;
  final String? pdfUrl;
  final String? videoUrl;

  factory StudyContent.fromJson(Map<String, Object?> json) {
    return StudyContent(
      id: (json['id'] as num).toInt(),
      titulo: (json['titulo'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? '',
      pdfUrl: (json['pdf_url'] as String?) ?? (json['url'] as String?),
      videoUrl: json['video_url'] as String?,
    );
  }
}
