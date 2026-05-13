import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/installment_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';

class InstallmentListScreen extends StatefulWidget {
  const InstallmentListScreen({super.key});

  @override
  State<InstallmentListScreen> createState() => _InstallmentListScreenState();
}

class _InstallmentListScreenState extends State<InstallmentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      final cpf = authController.currentCpf;
      if (cpf != null) {
        context.read<InstallmentController>().fetchInstallments(cpf);
      }
    });
  }

  String _formatStoreName(String rawName) {
    try {
      final parts = rawName.split('-');
      if (parts.isEmpty) return rawName;

      // Part 1: "Loja 01"
      String prefix = parts[0].trim();

      // Part 2: "COMETA CALCADOS..."
      String name = parts.length > 1 ? parts[1].trim() : '';

      // Title Case for name
      name = name
          .split(' ')
          .map(
            (word) =>
                word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                    : '',
          )
          .join(' ');

      return '$prefix $name'.trim();
    } catch (e) {
      return rawName;
    }
  }

  Future<void> _refresh() async {
    final authController = context.read<AuthController>();
    final cpf = authController.currentCpf;
    if (cpf != null) {
      await context.read<InstallmentController>().fetchInstallments(cpf);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Débitos'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Consumer<InstallmentController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.storeGroups.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // We handle errors via SnackBar mostly, but if empty list and error
            if (controller.error != null &&
                !controller.error!.contains("PIX pendente") &&
                !controller.error!.contains("apenas uma loja")) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text(controller.error!)),
                  ),
                ],
              );
            }

            if (controller.storeGroups.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text('Nenhum débito encontrado.'),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: 120,
              ), // Espaço para o bottomSheet
              itemCount: controller.storeGroups.length,
              itemBuilder: (context, index) {
                final group = controller.storeGroups[index];
                final hasPendingPix = controller.hasPendingPix(
                  group.filialCode,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    shape: Border.all(color: Colors.transparent),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatStoreName(group.storeName),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: hasPendingPix ? Colors.grey : null,
                            ),
                          ),
                        ),
                        if (hasPendingPix)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.pending_actions,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    subtitle:
                        hasPendingPix
                            ? const Text(
                              "PIX pendente",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            )
                            : null,
                    children:
                        group.items.map((item) {
                          final isSelected = controller.isSelected(item.id);
                          return CheckboxListTile(
                            activeColor: AppColors.primary,
                            title: Text(
                              item.description,
                              style: TextStyle(
                                color: hasPendingPix ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Text("Vencimento: ${item.dueDate}"),
                            secondary: Text(
                              NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$',
                              ).format(item.value),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: hasPendingPix ? Colors.grey : null,
                              ),
                            ),
                            value: isSelected,
                            onChanged:
                                hasPendingPix
                                    ? null // Disable checkbox
                                    : (bool? value) {
                                      controller.toggleSelection(item.id);
                                    },
                          );
                        }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomSheet: Consumer<InstallmentController>(
        builder: (context, controller, child) {
          final total = controller.totalSelectedAmount;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Selecionado"),
                      Text(
                        NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                        ).format(total),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.primary, fontSize: 24),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.withValues(
                        alpha: 0.5,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed:
                        total > 0 && !controller.isLoading
                            ? () => _showPixPayment(context, controller)
                            : null,
                    child:
                        controller.isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Image.asset(
                              'assets/pix.png',
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPixPayment(
    BuildContext context,
    InstallmentController controller,
  ) async {
    final result = await controller.paySelected();

    if (!context.mounted) return;

    if (result != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (context) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    "Pagamento via PIX",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: QrImageView(
                        data: result['pix_copy_paste'],
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Código Copia e Cola",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            result['pix_copy_paste'],
                            style: const TextStyle(fontFamily: 'Courier'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: result['pix_copy_paste']),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código PIX copiado!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Refresh state to update disabled items
                        setState(() {});
                      },
                      child: const Text("Fechar"),
                    ),
                  ),
                ],
              ),
            ),
      );
    } else if (controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error!), backgroundColor: Colors.red),
      );
    }
  }
}
