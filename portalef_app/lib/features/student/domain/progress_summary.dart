class ProgressSummary {
  const ProgressSummary({
    required this.tempoHoje,
    required this.percentAcertos,
    required this.diasSeguidos,
  });

  final int tempoHoje;
  final int percentAcertos;
  final int diasSeguidos;

  factory ProgressSummary.fromJson(Map<String, Object?> json) {
    return ProgressSummary(
      tempoHoje: (json['tempoHoje'] as num?)?.toInt() ?? 0,
      percentAcertos: (json['percentAcertos'] as num?)?.toInt() ?? 0,
      diasSeguidos: (json['diasSeguidos'] as num?)?.toInt() ?? 0,
    );
  }
}

