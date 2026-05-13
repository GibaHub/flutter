import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/settings_controller.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Segurança')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.fingerprint,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Biometria',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use sua impressão digital ou reconhecimento facial para entrar no app com mais rapidez e segurança.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_canCheckBiometrics)
                    SwitchListTile(
                      title: const Text('Ativar Biometria'),
                      subtitle: const Text('Login com FaceID ou TouchID'),
                      value: settings.isBiometricsEnabled,
                      onChanged: (value) {
                        context.read<SettingsController>().toggleBiometrics(
                          value,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Biometria ativada com sucesso!'
                                  : 'Biometria desativada.',
                            ),
                          ),
                        );
                      },
                      secondary: const Icon(Icons.security),
                    )
                  else
                    const ListTile(
                      leading: Icon(Icons.error_outline, color: Colors.orange),
                      title: Text('Biometria indisponível'),
                      subtitle: Text(
                        'Seu dispositivo não suporta biometria ou ela não está configurada.',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.devices),
              title: Text('Dispositivos Conectados'),
              subtitle: Text('Gerencie os aparelhos com acesso à sua conta'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
