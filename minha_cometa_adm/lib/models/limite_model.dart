class LimiteModel {
  final String filial;
  final String cliente;
  final String nome;
  final String limite;
  final String data;
  final String solicitante;

  LimiteModel({
    required this.filial,
    required this.cliente,
    required this.nome,
    required this.limite,
    required this.data,
    required this.solicitante,
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

  factory LimiteModel.fromJson(Map<String, dynamic> json) {
    return LimiteModel(
      filial: _normalizeFilial(json['FILIAL']),
      cliente: json['CLIENTE'] ?? '',
      nome: json['NOME'] ?? '',
      limite: json['LIMITE'] ?? '',
      data: json['DATA'] ?? '',
      solicitante: json['SOLICITANTE'] ?? '',
    );
  }
}
