class ClienteDetalhadoModel {
  final String codigo;
  final String nome;
  final String limite;
  final String vendas;
  final String totalPago;
  final String totalAberto;
  final String mediaAtraso;
  final String titulosAtraso;
  final String valorAtraso;
  final String totalDesconto;
  final String totalJuros;
  final String tempoLimite;

  ClienteDetalhadoModel({
    required this.codigo,
    required this.nome,
    required this.limite,
    required this.vendas,
    required this.totalPago,
    required this.totalAberto,
    required this.mediaAtraso,
    required this.titulosAtraso,
    required this.valorAtraso,
    required this.totalDesconto,
    required this.totalJuros,
    required this.tempoLimite,
  });

  factory ClienteDetalhadoModel.fromJson(Map<String, dynamic> json) {
    return ClienteDetalhadoModel(
      codigo: json['CODIGO'] ?? '',
      nome: json['NOME'] ?? '',
      limite: json['LIMITE'] ?? '',
      vendas: json['VENDAS'] ?? '',
      totalPago: json['TOTAL_PAGO'] ?? '',
      totalAberto: json['TOTAL_ABERTO'] ?? '',
      mediaAtraso: json['MEDIA_ATRASO'] ?? '',
      titulosAtraso: json['TITULOS_ATRASO'] ?? '',
      valorAtraso: json['VALOR_ATRASO'] ?? '',
      totalDesconto: json['TOTAL_DESCONTO'] ?? '',
      totalJuros: json['TOTAL_JUROS'] ?? '',
      tempoLimite: json['TEMPO_LIMITE'] ?? '',
    );
  }
}