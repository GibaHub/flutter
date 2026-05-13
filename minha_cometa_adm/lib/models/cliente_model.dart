
class ClienteModel {
  final String codigo;
  final String nome;
  final double limiteAtual;

  ClienteModel({
    required this.codigo,
    required this.nome,
    required this.limiteAtual,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      codigo: json['codigo'].toString(),
      nome: json['nome'] ?? '',
      limiteAtual: (json['limiteAtual'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nome': nome,
      'limiteAtual': limiteAtual,
    };
  }
}
