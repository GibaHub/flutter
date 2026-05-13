class RankingVendasModel {
  final String filial;
  final String totalPorFilial;
  final String dinheiro;
  final String credito;
  final String debito;
  final String carne;
  final String pix;
  final String valorTotal;
  final String atendimentos;
  final String meta;
  final String ticket;
  final String percentualMeta;
  final String totalPorDia;

  RankingVendasModel({
    required this.filial,
    required this.totalPorFilial,
    required this.dinheiro,
    required this.credito,
    required this.debito,
    required this.carne,
    required this.pix,
    required this.valorTotal,
    required this.atendimentos,
    required this.meta,
    required this.ticket,
    required this.percentualMeta,
    required this.totalPorDia,
  });

  static String _normalizeFilial(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '';

    final leadingMatch =
        RegExp(r'^\s*(?:LOJA\s*)?(\d{1,2})\b', caseSensitive: false)
            .firstMatch(raw);
    if (leadingMatch != null) {
      return leadingMatch.group(1)!.padLeft(2, '0');
    }

    final anyMatch = RegExp(r'(\d{1,2})').firstMatch(raw);
    if (anyMatch != null) {
      return anyMatch.group(1)!.padLeft(2, '0');
    }

    return raw.padLeft(2, '0');
  }

  factory RankingVendasModel.fromJson(Map<String, dynamic> json) {
    return RankingVendasModel(
      filial: _normalizeFilial(json['FILIAL']),
      totalPorFilial: json['TOTAL_POR_FILIAL'] ?? '',
      dinheiro: json['DINHEIRO'] ?? '',
      credito: json['CREDITO'] ?? '',
      debito: json['DEBITO'] ?? '',
      carne: json['CARNE'] ?? '',
      pix: json['PIX'] ?? '',
      valorTotal: json['VALOR_TOTAL'] ?? '',
      atendimentos: json['ATENDIMENTOS'] ?? '',
      meta: json['META'] ?? '',
      ticket: json['TICKET'] ?? '',
      percentualMeta: json['PERCENTUAL_META'] ?? '',
      totalPorDia: json['TOTAL_POR_DIA'] ?? '',
    );
  }
}
