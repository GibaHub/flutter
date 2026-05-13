import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _canUseBiometrics = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    final controller = context.read<AuthController>();
    final navigator = Navigator.of(context);
    final isEnabled = await controller.isBiometricsEnabled();
    if (isEnabled && mounted) {
      setState(() {
        _canUseBiometrics = true;
      });
      final success = await controller.loginWithBiometrics();
      if (success && mounted) {
        navigator.pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),

                // Inputs
                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CpfInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: "CPF",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor:
                        isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe seu CPF';
                    }
                    if (!UtilBrasilFields.isCPFValido(value)) {
                      return 'CPF inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: "Senha",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed:
                          () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor:
                        isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Senha muito curta';
                    }
                    return null;
                  },
                ),

                // Esqueci minha senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Esqueci minha senha",
                      style: GoogleFonts.openSans(
                        color:
                            isDark ? Colors.grey[400] : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botão de Login
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        authController.isLoading
                            ? null
                            : () => _handleLogin(authController),
                    child:
                        authController.isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              "ENTRAR",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
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

                if (_canUseBiometrics)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: IconButton(
                        iconSize: 48,
                        icon: const Icon(
                          Icons.fingerprint,
                          color: AppColors.primary,
                        ),
                        onPressed: () async {
                          final controller = context.read<AuthController>();
                          final navigator = Navigator.of(context);
                          final success =
                              await controller.loginWithBiometrics();

                          if (success) {
                            navigator.pushReplacementNamed('/home');
                          }
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Primeiro acesso? ",
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Cadastre-se",
                        style: GoogleFonts.openSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(AuthController controller) async {
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);
      final success = await controller.login(
        _cpfController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        final isBiometricsEnabled = await controller.isBiometricsEnabled();
        if (!mounted) return;

        if (!isBiometricsEnabled) {
          _showBiometricDialog(
            controller,
            _cpfController.text,
            _passwordController.text,
          );
        } else {
          navigator.pushReplacementNamed('/home');
        }
      }
    }
  }

  void _showBiometricDialog(
    AuthController controller,
    String cpf,
    String password,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Biometria"),
            content: const Text(
              "Deseja ativar o acesso com Biometria/FaceID para os próximos acessos?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text(
                  "Agora Não",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await controller.enableBiometrics(cpf, password);
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Biometria ativada com sucesso!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text("Ativar Agora"),
              ),
            ],
          ),
    );
  }
}
