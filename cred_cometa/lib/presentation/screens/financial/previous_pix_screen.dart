import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/installment_controller.dart';
import '../../../core/theme/app_colors.dart';

class PreviousPixScreen extends StatelessWidget {
  const PreviousPixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PIX Pendentes')),
      body: Consumer<InstallmentController>(
        builder: (context, controller, child) {
          if (controller.pixKeys.isEmpty) {
            return const Center(child: Text('Nenhum PIX pendente encontrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pixKeys.length,
            itemBuilder: (context, index) {
              final key = controller.pixKeys[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loja ${key.filial}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                key.pixKey,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: key.pixKey),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Código copiado!"),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Este PIX aguarda confirmação de pagamento.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
