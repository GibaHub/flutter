import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/controllers/installment_controller.dart';

class PixHistoryScreen extends StatelessWidget {
  const PixHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Meus PIX Gerados")),
      body: Consumer<InstallmentController>(
        builder: (context, controller, child) {
          if (controller.pixKeys.isEmpty) {
            return Center(
              child: Text(
                "Nenhum PIX gerado recentemente.",
                style: GoogleFonts.lato(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pixKeys.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final pix = controller.pixKeys[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    FontAwesomeIcons.pix,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  "Loja ${pix.filial}",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                subtitle: Text(
                  NumberFormat.currency(
                    locale: 'pt_BR',
                    symbol: 'R\$',
                  ).format(pix.value),
                  style: GoogleFonts.lato(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pix.pixKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chave PIX copiada!")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
