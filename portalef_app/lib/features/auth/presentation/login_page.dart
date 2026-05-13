import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/biometric_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final ProviderSubscription<AsyncValue<AuthSession?>> _authSub;
  var _enableBiometrics = false;

  @override
  void initState() {
    super.initState();
    _authSub = ref.listenManual(authControllerProvider, (previous, next) {
      final error = next.error;
      if (error == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_messageFromError(error)),
          backgroundColor: AppColors.error,
        ),
      );
    });
  }

  @override
  void dispose() {
    _authSub.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;
    final biometricSupportAsync = ref.watch(biometricSupportProvider);
    final biometricState = ref.watch(biometricControllerProvider).valueOrNull;

    if (biometricState != null &&
        biometricState.enabled &&
        !_enableBiometrics) {
      _enableBiometrics = true;
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.royalBlue, Color(0xFF00B4D8)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 124,
                                width: 124,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bem-vindo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Faça login para continuar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.darkBg.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              hintText: 'seu@email.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.isEmpty) return 'Informe o e-mail';
                              if (!text.contains('@')) return 'E-mail inválido';
                              return null;
                            },
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.isEmpty) return 'Informe a senha';
                              return null;
                            },
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 12),
                          biometricSupportAsync.when(
                            data: (supported) {
                              if (!supported) return const SizedBox.shrink();
                              return SwitchListTile(
                                value: _enableBiometrics,
                                onChanged:
                                    isLoading
                                        ? null
                                        : (value) {
                                          setState(
                                            () => _enableBiometrics = value,
                                          );
                                        },
                                title: const Text(
                                  'Usar biometria neste dispositivo',
                                ),
                                subtitle: Text(
                                  _enableBiometrics
                                      ? 'Será solicitado ao abrir o app'
                                      : 'Opcional',
                                ),
                                contentPadding: EdgeInsets.zero,
                              );
                            },
                            error: (_, __) => const SizedBox.shrink(),
                            loading: () => const SizedBox(height: 56),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      if (!(_formKey.currentState?.validate() ??
                                          false)) {
                                        return;
                                      }
                                      await ref
                                          .read(authControllerProvider.notifier)
                                          .login(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                          );
                                      final session =
                                          ref
                                              .read(authControllerProvider)
                                              .valueOrNull;
                                      if (session != null) {
                                        await ref
                                            .read(
                                              biometricControllerProvider
                                                  .notifier,
                                            )
                                            .setEnabled(
                                              _enableBiometrics,
                                              unlockNow: true,
                                            );
                                      }
                                    },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child:
                                isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Entrar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _messageFromError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final msg = data['error']?.toString();
        if (msg != null && msg.trim().isNotEmpty) {
          return msg.trim();
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Tempo esgotado ao conectar';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Sem conexão com o servidor';
      }
    }

    final raw = error.toString();
    if (raw.contains('Credenciais inválidas')) return 'Credenciais inválidas';
    if (raw.contains('Email e senha são obrigatórios')) {
      return 'Email e senha são obrigatórios';
    }
    return 'Falha ao realizar login';
  }
}
