class TitulosReceberModel {
  final String filial;
  final String totalAReceberMes;
  final String valorRecebidoMes;
  final String saldoAbertoMes;
  final String saldoAVencerMes;
  final String inadimplenciaMes;
  final String percentualInadimplenciaMes;
  final String renegRecebidaMes;
  final String renegAbertoMes;
  final String renegInadimplenciaMes;

  TitulosReceberModel({
    required this.filial,
    required this.totalAReceberMes,
    required this.valorRecebidoMes,
    required this.saldoAbertoMes,
    required this.saldoAVencerMes,
    required this.inadimplenciaMes,
    required this.percentualInadimplenciaMes,
    required this.renegRecebidaMes,
    required this.renegAbertoMes,
    required this.renegInadimplenciaMes,
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

  factory TitulosReceberModel.fromJson(Map<String, dynamic> json) {
    return TitulosReceberModel(
      filial: _normalizeFilial(json['FILIAL']),
      totalAReceberMes: json['TOTAL_A_RECEBER_MES'] ?? '0,00',
      valorRecebidoMes: json['VALOR_RECEBIDO_MES'] ?? '0,00',
      saldoAbertoMes: json['SALDO_ABERTO_MES'] ?? '0,00',
      saldoAVencerMes: json['SALDO_A_VENCER_MES'] ?? '0,00',
      inadimplenciaMes: json['INADIMPLENCIA_DO_MES'] ?? '0,00',
      percentualInadimplenciaMes: json['PERCENTUAL_INADIMPLENCIA_MES'] ?? '0%',
      renegRecebidaMes: json['RENEG_RECEBIDAS_MES'] ?? '0,00',
      renegAbertoMes: json['RENEG_ABERTO_MES'] ?? '0,00',
      renegInadimplenciaMes: json['RENEG_INADIMPLENCIA_MES'] ?? '0,00',
    );
  }
}

class TitulosPagarModel {
  final String filial;
  final String valorTotalPagar;
  final String valorPago;
  final String valorEmAberto;
  final String valorEmAtraso;

  TitulosPagarModel({
    required this.filial,
    required this.valorTotalPagar,
    required this.valorPago,
    required this.valorEmAberto,
    required this.valorEmAtraso,
  });

  factory TitulosPagarModel.fromJson(Map<String, dynamic> json) {
    return TitulosPagarModel(
      filial: TitulosReceberModel._normalizeFilial(json['FILIAL']),
      valorTotalPagar: json['VALOR_TOTAL_PAGAR'] ?? '0,00',
      valorPago: json['VALOR_PAGO'] ?? '0,00',
      valorEmAberto: json['VALOR_EM_ABERTO'] ?? '0,00',
      valorEmAtraso: json['VALOR_EM_ATRASO'] ?? '0,00',
    );
  }
}

class TitulosResponseModel {
  final List<TitulosReceberModel> titulosReceber;
  final List<TitulosPagarModel> titulosPagar;

  TitulosResponseModel({
    required this.titulosReceber,
    required this.titulosPagar,
  });

  factory TitulosResponseModel.fromJson(Map<String, dynamic> json) {
    return TitulosResponseModel(
      titulosReceber: (json['TITULOS_RECEBER'] as List<dynamic>? ?? [])
          .map((item) => TitulosReceberModel.fromJson(item))
          .toList(),
      titulosPagar: (json['TITULOS_PAGAR'] as List<dynamic>? ?? [])
          .map((item) => TitulosPagarModel.fromJson(item))
          .toList(),
    );
  }
}
