import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';

import 'create_password_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.sms_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                "Verificação",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Enviamos um código de 6 dígitos para o seu WhatsApp.",
                style: GoogleFonts.openSans(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Campo de OTP Simples (simulando PinPut)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "000000",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              if (authController.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    authController.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      authController.isLoading
                          ? null
                          : () => _handleVerify(context, authController),
                  child:
                      authController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("VALIDAR CÓDIGO"),
                ),
              ),

              const SizedBox(height: 24),
              TextButton(
                onPressed:
                    authController.isLoading
                        ? null
                        : () => _handleResend(context, authController),
                child: const Text("Reenviar Código"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleVerify(BuildContext context, AuthController controller) async {
    final success = await controller.verifyOtp(_otpController.text);

    if (success && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePasswordScreen()),
      );
    }
  }

  void _handleResend(BuildContext context, AuthController controller) async {
    if (controller.currentCpf != null && controller.currentPhone != null) {
      final success = await controller.resendOtp(
        controller.currentCpf!,
        controller.currentPhone!,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Código reenviado com sucesso!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: Dados de contato não encontrados")),
      );
    }
  }
}
