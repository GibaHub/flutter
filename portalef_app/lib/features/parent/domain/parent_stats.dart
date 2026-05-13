class ParentStats {
  const ParentStats({
    required this.global,
    required this.evolution,
    required this.subjects,
    required this.recent,
  });

  final ParentGlobalStats global;
  final List<ParentEvolutionPoint> evolution;
  final List<ParentSubjectStat> subjects;
  final List<ParentRecentActivity> recent;

  factory ParentStats.fromJson(Map<String, Object?> json) {
    final evolutionRaw = (json['evolution'] as List?) ?? const [];
    final subjectsRaw = (json['subjects'] as List?) ?? const [];
    final recentRaw = (json['recent'] as List?) ?? const [];

    return ParentStats(
      global: ParentGlobalStats.fromJson(
        Map<String, Object?>.from((json['global'] as Map?) ?? const {}),
      ),
      evolution: evolutionRaw
          .whereType<Map>()
          .map((m) => Map<String, Object?>.from(m))
          .map(ParentEvolutionPoint.fromJson)
          .toList(growable: false),
      subjects: subjectsRaw
          .whereType<Map>()
          .map((m) => Map<String, Object?>.from(m))
          .map(ParentSubjectStat.fromJson)
          .toList(growable: false),
      recent: recentRaw
          .whereType<Map>()
          .map((m) => Map<String, Object?>.from(m))
          .map(ParentRecentActivity.fromJson)
          .toList(growable: false),
    );
  }
}

class ParentGlobalStats {
  const ParentGlobalStats({
    required this.tempoTotal,
    required this.mediaAcertos,
    required this.atividadesConcluidas,
    required this.progressoTrilha,
  });

  final int tempoTotal;
  final int mediaAcertos;
  final int atividadesConcluidas;
  final int progressoTrilha;

  factory ParentGlobalStats.fromJson(Map<String, Object?> json) {
    return ParentGlobalStats(
      tempoTotal: (json['tempoTotal'] as num?)?.toInt() ?? 0,
      mediaAcertos: (json['mediaAcertos'] as num?)?.toInt() ?? 0,
      atividadesConcluidas: (json['atividadesConcluidas'] as num?)?.toInt() ?? 0,
      progressoTrilha: (json['progressoTrilha'] as num?)?.toInt() ?? 0,
    );
  }
}

class ParentEvolutionPoint {
  const ParentEvolutionPoint({
    required this.weekStart,
    required this.label,
    required this.nota,
  });

  final DateTime? weekStart;
  final String? label;
  final int nota;

  factory ParentEvolutionPoint.fromJson(Map<String, Object?> json) {
    final raw = json['week_start'] as String?;
    return ParentEvolutionPoint(
      weekStart: raw == null ? null : DateTime.tryParse(raw),
      label: json['label'] as String?,
      nota: (json['nota'] as num?)?.toInt() ?? 0,
    );
  }
}

class ParentSubjectStat {
  const ParentSubjectStat({
    required this.subject,
    required this.hours,
    required this.count,
  });

  final String subject;
  final double hours;
  final int count;

  factory ParentSubjectStat.fromJson(Map<String, Object?> json) {
    return ParentSubjectStat(
      subject: (json['subject'] as String?) ?? '',
      hours: double.tryParse((json['hours'] ?? 0).toString()) ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ParentRecentActivity {
  const ParentRecentActivity({
    required this.dataRegistro,
    required this.tempoEstudoDiario,
    required this.acertos,
    required this.questoesRespondidas,
    required this.titulo,
    required this.materia,
    required this.tipo,
  });

  final DateTime? dataRegistro;
  final int tempoEstudoDiario;
  final int acertos;
  final int questoesRespondidas;
  final String titulo;
  final String materia;
  final String tipo;

  factory ParentRecentActivity.fromJson(Map<String, Object?> json) {
    final dateRaw = json['data_registro'] as String?;
    return ParentRecentActivity(
      dataRegistro: dateRaw == null ? null : DateTime.tryParse(dateRaw),
      tempoEstudoDiario: (json['tempo_estudo_diario'] as num?)?.toInt() ?? 0,
      acertos: (json['acertos'] as num?)?.toInt() ?? 0,
      questoesRespondidas: (json['questoes_respondidas'] as num?)?.toInt() ?? 0,
      titulo: (json['titulo'] as String?) ?? '',
      materia: (json['materia'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? '',
    );
  }
}

