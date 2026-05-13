class VendasOnlineModel {
  final String filial;
  final String plataforma;
  final String valorTotal;
  final String quantidadePedidos;
  final String ticketMedio;
  final String percentualCrescimento;
  final String dataVenda;
  final String statusPedido;
  final String metodoPagamento;

  VendasOnlineModel({
    required this.filial,
    required this.plataforma,
    required this.valorTotal,
    required this.quantidadePedidos,
    required this.ticketMedio,
    required this.percentualCrescimento,
    required this.dataVenda,
    required this.statusPedido,
    required this.metodoPagamento,
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

  factory VendasOnlineModel.fromJson(Map<String, dynamic> json) {
    return VendasOnlineModel(
      filial: _normalizeFilial(json['FILIAL']),
      plataforma: json['PLATAFORMA']?.toString() ?? '',
      valorTotal: json['VALOR_TOTAL']?.toString() ?? '0',
      quantidadePedidos: json['QTD_PEDIDOS']?.toString() ?? '0',
      ticketMedio: json['TICKET_MEDIO']?.toString() ?? '0',
      percentualCrescimento: json['PERC_CRESCIMENTO']?.toString() ?? '0',
      dataVenda: json['DATA_VENDA']?.toString() ?? '',
      statusPedido: json['STATUS_PEDIDO']?.toString() ?? '',
      metodoPagamento: json['METODO_PAGAMENTO']?.toString() ?? '',
    );
  }
}
