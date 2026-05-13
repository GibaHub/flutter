import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SelecaoDescontoPage extends StatelessWidget {
  const SelecaoDescontoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Tipo de Desconto'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionCard(
              context,
              title: 'Desconto na Venda',
              icon: Icons.shopping_cart,
              color: Colors.blue,
              onTap: () {
                debugPrint('Navegando para desconto na venda');
                Navigator.pushNamed(context, '/descontos/venda');
              },
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              title: 'Desconto na Baixa',
              icon: Icons.money_off,
              color: Colors.green,
              onTap: () {
                debugPrint('Navegando para desconto na baixa');
                Navigator.pushNamed(context, '/descontos/baixa');
              },
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              title: 'Alterar Entrada',
              icon: Icons.edit_calendar,
              color: Colors.orange,
              onTap: () {
                debugPrint('Navegando para alterar entrada');
                Navigator.pushNamed(context, '/descontos/alterar-entrada');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
