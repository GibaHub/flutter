class InadimplenciaModel {
  final String filial;
  final String anoBase;
  final String totalAReceber;
  final String negociados;
  final String atraso;
  final String nPagos;
  final String perct;
  final String valorPago;

  InadimplenciaModel({
    required this.filial,
    required this.anoBase,
    required this.totalAReceber,
    required this.negociados,
    required this.atraso,
    required this.nPagos,
    required this.perct,
    required this.valorPago,
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

  factory InadimplenciaModel.fromJson(Map<String, dynamic> json) {
    return InadimplenciaModel(
      filial: _normalizeFilial(json['FILIAL']),
      anoBase: json['ANO_BASE']?.toString() ?? '',
      totalAReceber: json['TOTAL_A_RECEBER']?.toString() ?? '0',
      negociados: json['NEGOCIADOS']?.toString() ?? '0',
      atraso: json['ATRASO']?.toString() ?? '0',
      nPagos: json['NPAGOS']?.toString() ?? '0',
      perct: json['PERCT']?.toString() ?? '',
      valorPago: json['VALOR_PAGO']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FILIAL': filial,
      'ANO_BASE': anoBase,
      'TOTAL_A_RECEBER': totalAReceber,
      'NEGOCIADOS': negociados,
      'ATRASO': atraso,
      'NPAGOS': nPagos,
      'PERCT': perct,
      'VALOR_PAGO': valorPago,
    };
  }

  // Método para formatar valores monetários
  String get totalAReceberFormatado {
    return 'R\$ $totalAReceber';
  }

  String get negociadosFormatado {
    return 'R\$ $negociados';
  }

  String get atrasoFormatado {
    return 'R\$ $atraso';
  }

  String get nPagosFormatado {
    return 'R\$ $nPagos';
  }

  String get valorPagoFormatado {
    return 'R\$ $valorPago';
  }

  String get percentualFormatado {
    return perct.isEmpty ? '0%' : '$perct%';
  }
}
