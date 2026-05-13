import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/biometric_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  var _unlocking = false;
  String? _error;
  var _attemptedAutoUnlock = false;

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final biometricAsync = ref.watch(biometricControllerProvider);

    final session = authAsync.valueOrNull;
    final biometric = biometricAsync.valueOrNull;
    final needsUnlock = session != null && (biometric?.enabled ?? false) && !(biometric?.unlocked ?? false);

    if (needsUnlock && !_attemptedAutoUnlock && !_unlocking) {
      _attemptedAutoUnlock = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _unlock();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.royalBlue,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset('assets/images/logo.png', height: 96, width: 96),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PortalEF',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    needsUnlock ? 'Desbloqueie para continuar' : 'Carregando...',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 24),
                  if (needsUnlock) ...[
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _unlocking ? null : _unlock,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.royalBlue,
                        ),
                        child: _unlocking
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Usar biometria'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _unlocking
                            ? null
                            : () async {
                                await ref.read(authControllerProvider.notifier).logout();
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text('Sair'),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    setState(() {
      _unlocking = true;
      _error = null;
    });
    final ok = await ref.read(biometricControllerProvider.notifier).unlock();
    if (!ok && mounted) {
      setState(() {
        _unlocking = false;
        _error = 'Não foi possível autenticar.';
      });
      return;
    }
    if (mounted) {
      setState(() {
        _unlocking = false;
      });
    }
  }
}

