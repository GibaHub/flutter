class PixKeyModel {
  final String filial;
  final String pixKey;
  final double value;

  PixKeyModel({
    required this.filial,
    required this.pixKey,
    required this.value,
  });

  factory PixKeyModel.fromJson(Map<String, dynamic> json) {
    String valStr = (json['VALOR'] ?? '0').toString();
    valStr = valStr.replaceAll(',', '.'); // Ensure dot for parsing if needed

    return PixKeyModel(
      filial: (json['FILIAL'] ?? '').toString().trim(),
      pixKey: (json['CHAVE_PIX'] ?? '').toString().trim(),
      value: double.tryParse(valStr) ?? 0.0,
    );
  }
}
