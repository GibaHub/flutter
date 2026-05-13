// Card com informações da loja
import 'package:flutter/material.dart';

class LojaCard extends StatelessWidget {
  final String nome;
  final String numero;
  final double valorMensal;
  final double valorDiario;

  const LojaCard({
    super.key,
    required this.nome,
    required this.numero,
    required this.valorMensal,
    required this.valorDiario,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$nome ',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'R\$ ${valorMensal.toStringAsFixed(2)} / mês',
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          Text(
            'R\$ ${valorDiario.toStringAsFixed(2)} - Vendas no dia',
            // ignore: deprecated_member_use
            style: TextStyle(color: textColor.withOpacity(0.8)),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(onPressed: () {}, child: const Text('Detalhar')),
          ),
        ],
      ),
    );
  }
}
