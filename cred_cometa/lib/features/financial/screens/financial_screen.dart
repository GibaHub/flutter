import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/controllers/installment_controller.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../data/models/installment_model.dart';
// import '../../../presentation/screens/financial/installment_list_screen.dart'; // Reuse logic/UI if needed, but we are implementing custom here

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      if (authController.currentCpf != null) {
        context.read<InstallmentController>().fetchInstallments(
          authController.currentCpf!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Meus Carnês"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.pix),
            onPressed:
                () => _showPixHistory(
                  context,
                  context.read<InstallmentController>(),
                ),
            tooltip: "Meus PIX",
          ),
        ],
      ),
      body: Consumer<InstallmentController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final authController = context.read<AuthController>();
                        if (authController.currentCpf != null) {
                          controller.fetchInstallments(
                            authController.currentCpf!,
                          );
                        }
                      },
                      child: const Text("Tentar Novamente"),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCreditCard(context),
                    const SizedBox(height: 24),
                    _buildTimelineTitle(),
                    const SizedBox(height: 16),
                    if (controller.storeGroups.isEmpty)
                      Center(
                        child: Text(
                          "Nenhuma parcela encontrada.",
                          style: GoogleFonts.lato(color: Colors.grey),
                        ),
                      )
                    else
                      _buildInstallmentTimeline(context, controller),
                    const SizedBox(height: 100), // Space for bottom sheet
                  ],
                ),
              ),
              if (controller.totalSelectedAmount > 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomPaymentBar(context, controller),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context) {
    final authController = context.read<AuthController>();
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark elegant background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Crediário Cometa",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Removed Visa Icon
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authController.userName?.toUpperCase() ?? "CLIENTE",
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Limite Disponível",
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Em breve",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(
            "Linha do Tempo",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentTimeline(
    BuildContext context,
    InstallmentController controller,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.storeGroups.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, groupIndex) {
        final group = controller.storeGroups[groupIndex];
        // Sort items by due date
        final sortedItems = List<InstallmentModel>.from(group.items)
          ..sort((a, b) => a.dueDateDt.compareTo(b.dueDateDt));

        // Check if this store has a pending PIX
        final hasPendingPix = controller.pixKeys.any(
          (k) => k.filial == group.filialCode,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          color: hasPendingPix ? Colors.orange : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
          child: ExpansionTile(
            initiallyExpanded: false,
            shape: const Border(), // Remove borders when expanded
            leading: Icon(
              Icons.store,
              color: hasPendingPix ? Colors.white : AppColors.primary,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    group.storeName,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          hasPendingPix
                              ? Colors.white
                              : Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                if (hasPendingPix)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "PIX Pendente",
                      style: GoogleFonts.lato(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            children:
                sortedItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == sortedItems.length - 1;

                  final status = _determineStatus(item);
                  final formattedDate = _formatDate(item.dueDateDt);
                  final formattedValue = NumberFormat.currency(
                    locale: 'pt_BR',
                    symbol: 'R\$',
                  ).format(item.value);
                  final isSelected = controller.isSelected(item.id);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              _buildStatusIcon(status),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: Colors.grey[300],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: InkWell(
                                onTap:
                                    hasPendingPix
                                        ? () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Já existe um PIX gerado para esta loja.",
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                        : () =>
                                            controller.toggleSelection(item.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppColors.primary.withValues(
                                              alpha: 0.1,
                                            )
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : Colors.grey[200]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Parcela ${item.installment}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Fatura: ${item.number}",
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Vencimento: $formattedDate",
                                        style: GoogleFonts.lato(
                                          color:
                                              status == 'late'
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formattedValue,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  String _determineStatus(InstallmentModel item) {
    if (item.status == 'PAID') return 'paid';

    // Parse date YYYY-MM-DD
    try {
      final dueDate = item.dueDateDt;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (dueDate.isBefore(today)) {
        return 'late';
      } else if (dueDate.difference(today).inDays > 30) {
        return 'future';
      } else {
        return 'open';
      }
    } catch (e) {
      return 'open';
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM', 'pt_BR').format(date).toUpperCase();
    } catch (e) {
      return '';
    }
  }

  Widget _buildStatusIcon(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'paid':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'late':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'open':
        color = Colors.blue;
        icon = Icons.circle_outlined;
        break;
      case 'future':
        color = Colors.grey;
        icon = Icons.access_time;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildBottomPaymentBar(
    BuildContext context,
    InstallmentController controller,
  ) {
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
                  ).format(controller.totalSelectedAmount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () => _showPixPayment(controller),
              child: Text(
                "Gerar PIX",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPixHistory(BuildContext context, InstallmentController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Text(
                  "Meus PIX Gerados",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.pixKeys.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "Nenhum PIX gerado recentemente.",
                        style: GoogleFonts.lato(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.qr_code,
                                  color: AppColors.primary,
                                ),
                                tooltip: "Ver QR Code",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text(
                                            "QR Code para Pagamento",
                                          ),
                                          content: SizedBox(
                                            width: 250,
                                            height: 250,
                                            child: Center(
                                              child: QrImageView(
                                                data: pix.pixKey,
                                                version: QrVersions.auto,
                                                size: 250.0,
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text("Fechar"),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: "Copiar Código",
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: pix.pixKey),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Chave PIX copiada!"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _showPixPayment(InstallmentController controller) async {
    try {
      final result = await controller.paySelected();
      if (!mounted) return;

      if (result != null) {
        String? qrCodeBase64 = result['qr_code_base64'];
        // Clean base64 string if necessary (sometimes comes with data:image/png;base64, prefix)
        if (qrCodeBase64 != null && qrCodeBase64.contains(',')) {
          qrCodeBase64 = qrCodeBase64.split(',').last;
        }

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder:
              (context) => Container(
                padding: const EdgeInsets.all(24),
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "PIX Gerado com Sucesso!",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (result['pix_copy_paste'] != null &&
                                (result['pix_copy_paste'] as String).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: QrImageView(
                                  data: result['pix_copy_paste'],
                                  version: QrVersions.auto,
                                  size: 250.0,
                                ),
                              )
                            else if (qrCodeBase64 != null &&
                                qrCodeBase64.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Image.memory(
                                  base64Decode(qrCodeBase64),
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const SizedBox(),
                                ),
                              ),
                            SelectableText(
                              result['pix_copy_paste'] ??
                                  "Erro ao gerar código",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.robotoMono(fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: result['pix_copy_paste'] ?? "",
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Código copiado!"),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text("Copiar Código"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
