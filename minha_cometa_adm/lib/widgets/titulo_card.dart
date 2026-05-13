import 'package:flutter/material.dart';
import '../models/titulos_model.dart';
import '../constants/app_colors.dart';

class TituloReceberCard extends StatelessWidget {
  final TitulosReceberModel titulo;

  const TituloReceberCard({Key? key, required this.titulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          'Filial: ${titulo.filial}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Total a Receber: R\$ ${titulo.totalAReceberMes}',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            Text(
              'Valor Recebido: R\$ ${titulo.valorRecebidoMes}',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Saldo em Aberto', 'R\$ ${titulo.saldoAbertoMes}', Colors.orange),
                _buildDetailRow('Saldo a Vencer', 'R\$ ${titulo.saldoAVencerMes}', Colors.blue),
                _buildDetailRow('Inadimplência', 'R\$ ${titulo.inadimplenciaMes}', Colors.red),
                _buildDetailRow('% Inadimplência', titulo.percentualInadimplenciaMes, Colors.red),
                const Divider(),
                const Text('Renegociações', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildDetailRow('Reneg. Recebidas', 'R\$ ${titulo.renegRecebidaMes}', Colors.green),
                _buildDetailRow('Reneg. em Aberto', 'R\$ ${titulo.renegAbertoMes}', Colors.orange),
                _buildDetailRow('Reneg. Inadimplência', 'R\$ ${titulo.renegInadimplenciaMes}', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TituloPagarCard extends StatelessWidget {
  final TitulosPagarModel titulo;

  const TituloPagarCard({Key? key, required this.titulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filial: ${titulo.filial}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Total a Pagar', 'R\$ ${titulo.valorTotalPagar}', AppColors.primary),
            _buildDetailRow('Valor Pago', 'R\$ ${titulo.valorPago}', Colors.green),
            _buildDetailRow('Valor em Aberto', 'R\$ ${titulo.valorEmAberto}', Colors.orange),
            _buildDetailRow('Valor em Atraso', 'R\$ ${titulo.valorEmAtraso}', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}