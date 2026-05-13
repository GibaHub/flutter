class VendedorRanking {
  final String nome;
  final double valorVendido;
  final double meta;
  final double percentual;

  VendedorRanking({
    required this.nome,
    required this.valorVendido,
    required this.meta,
    required this.percentual,
  });

  factory VendedorRanking.fromJson(Map<String, dynamic> json) {
    double parseCurrency(String value) {
      return double.tryParse(
            value
                .replaceAll('R', '')
                .replaceAll('.', '')
                .replaceAll(',', '.')
                .trim(),
          ) ??
          0.0;
    }

    double parsePercent(String value) {
      return double.tryParse(
            value.replaceAll('%', '').replaceAll(',', '.').trim(),
          ) ??
          0.0;
    }

    return VendedorRanking(
      nome: json['NOME'] ?? '',
      valorVendido: parseCurrency(json['VALOR_VENDIDO'] ?? '0'),
      meta: parseCurrency(json['META'] ?? '0'),
      percentual: parsePercent(json['PERCENTUAL'] ?? '0'),
    );
  }

  Map<String, dynamic> toJson() => {
        'NOME': nome,
        'VALOR_VENDIDO': valorVendido,
        'META': meta,
        'PERCENTUAL': percentual,
      };
}
