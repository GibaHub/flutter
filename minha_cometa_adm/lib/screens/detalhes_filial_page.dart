import 'package:flutter/material.dart';
import '../models/ranking_vendas_model.dart';
import '../constants/app_colors.dart';

class DetalhesFilialPage extends StatelessWidget {
  const DetalhesFilialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    
    if (arguments == null || arguments is! RankingVendasModel) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Dados não encontrados',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    
    final RankingVendasModel filial = arguments;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cards = [
      _buildCard(context, "Total Vendas", filial.totalPorFilial, Icons.attach_money,
          Colors.green),
      _buildCard(context, "Dinheiro", filial.dinheiro, Icons.money, Colors.blue),
      _buildCard(context, "PIX", filial.pix, Icons.qr_code, Colors.teal),
      _buildCard(context, "Crediário", filial.carne, Icons.description, Colors.orange),
      _buildCard(context, 
          "Crédito", filial.credito, Icons.credit_card, Colors.deepPurple),
      _buildCard(context, "Débito", filial.debito, Icons.credit_score, Colors.red),
      _buildCard(context, 
          "Valor Total", filial.valorTotal, Icons.paid, Colors.green.shade700),
      _buildCard(context, 
          "Atendimentos", filial.atendimentos, Icons.people, Colors.indigo),
      _buildCard(context, "Meta", filial.meta, Icons.flag, Colors.brown),
      _buildCard(context, 
          "Ticket Médio", filial.ticket, Icons.receipt_long, Colors.cyan),
      _buildCard(context, 
          "Meta (%)", filial.percentualMeta, Icons.percent, Colors.deepOrange),
      _buildCard(context, "Total do Dia", filial.totalPorDia, Icons.today, Colors.pink),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Vendas Loja ${filial.filial}', style: const TextStyle(color: Colors.white)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: isDark ? null : Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: cards,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.onSurfaceDark : AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
