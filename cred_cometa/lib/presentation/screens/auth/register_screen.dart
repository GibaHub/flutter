import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Vamos começar!",
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Preencha seus dados para criar sua conta Cred Cometa.",
                  style: GoogleFonts.openSans(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                _buildInput(
                  label: "Nome Completo",
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: "CPF",
                  controller: _cpfController,
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CpfInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: "Data de Nascimento",
                  controller: _birthDateController,
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    DataInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: "E-mail",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: "Celular (WhatsApp)",
                  controller: _phoneController,
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  helperText: "Enviaremos um código de validação.",
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter(),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        authController.isLoading
                            ? null
                            : () => _handleRegister(context, authController),
                    child:
                        authController.isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("CADASTRAR E ENVIAR TOKEN"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? helperText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        return null;
      },
    );
  }

  void _handleRegister(BuildContext context, AuthController controller) async {
    if (_formKey.currentState!.validate()) {
      final success = await controller.register(
        name: _nameController.text,
        cpf: _cpfController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        birthDate: _birthDateController.text,
      );

      if (success && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OtpScreen()),
        );
      }
    }
  }
}
