import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minha_cometa_adm/screens/cadastro_cliente_page.dart';
import 'package:minha_cometa_adm/screens/vendas_filiais_page.dart';
import 'package:minha_cometa_adm/screens/under_construction_page.dart';
import 'package:minha_cometa_adm/screens/titulos_page.dart';
import 'package:provider/provider.dart';
import 'pages/admin_users_page.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_routes_constants.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/detalhes_filial_page.dart';
import 'screens/limites_page.dart';
import 'screens/detalhes_cliente_page.dart';
import 'screens/splash_screen.dart';
import 'themes/app_theme.dart';
import 'screens/telefones_uteis_page.dart';
import 'screens/estoque_page.dart';
import 'screens/inadimplencia_parametros_page.dart';
import 'screens/descontos/selecao_desconto_page.dart';
import 'screens/descontos/desconto_baixa_page.dart';
import 'screens/descontos/desconto_venda_page.dart';
import 'screens/descontos/alterar_entrada_page.dart';
import 'screens/indenizacoes_page.dart';
import 'screens/indenizacoes_parametros_page.dart';
import 'screens/despesas_nova_page.dart';
import 'widgets/protected_route.dart';
import 'widgets/permission_guard.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exceptionAsString()}');
      if (details.stack != null) {
        debugPrint('Stack trace: ${details.stack}');
      }
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()..loadFromPrefs()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('Erro capturado: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'App Cometa',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
          ],
          locale: const Locale('pt', 'BR'),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            try {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const SplashScreen(),
                    settings: settings,
                  );
                case AppRoutes.login:
                  return MaterialPageRoute(
                    builder: (_) => const LoginPageWidget(),
                    settings: settings,
                  );
                case AppRoutes.home:
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(child: HomePage()),
                    settings: settings,
                  );
                case AppRoutes.clientes:
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'clientes',
                        child: CadastroClientePage(),
                      ),
                    ),
                    settings: settings,
                  );
                case AppRoutes.vendedores:
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'vendedores',
                        child: VendasFiliaisPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case AppRoutes.limites:
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'limites',
                        child: LimitesPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case AppRoutes.detalhesCliente:
                  final Map<String, dynamic> clienteArgs =
                      settings.arguments as Map<String, dynamic>? ??
                          {
                            'id': '',
                            'nome': '',
                            'filial': '',
                            'limite_atual': '',
                            'novo_limite': '',
                            'documento': '',
                            'telefone': '',
                            'email': '',
                            'endereco': '',
                            'data_solicitacao': '',
                            'status': 'Pendente',
                          };
                  return MaterialPageRoute(
                    builder: (_) => DetalhesClientePage(
                      cliente: clienteArgs,
                    ),
                    settings: settings,
                  );
                case AppRoutes.detalhesFilial:
                  return MaterialPageRoute(
                    builder: (_) => const DetalhesFilialPage(),
                    settings: settings,
                  );
                case '/indenizacoes':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'indenizacoes',
                        child: IndenizacoesParametrosPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/compras':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'compras',
                        child: UnderConstructionPage(pageTitle: 'Compras'),
                      ),
                    ),
                    settings: settings,
                  );
                case '/titulos':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'titulos',
                        child: TitulosPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/inadimplencia':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'inadimplencia',
                        child: InadimplenciaParametrosPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/usuarios-app':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'usuarios',
                        requireAdmin: true,
                        child: AdminUsersPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/despesas':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'despesas',
                        child: DespesasNovaPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/vendas':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'vendas',
                        child: UnderConstructionPage(pageTitle: 'Vendas'),
                      ),
                    ),
                    settings: settings,
                  );
                case '/telefones-uteis':
                  return MaterialPageRoute(
                    builder: (_) => const TelefonesUteisPage(),
                    settings: settings,
                  );
                case '/estoque':
                  return MaterialPageRoute(
                    builder: (_) => const EstoquePage(),
                    settings: settings,
                  );
                case '/pagamentos':
                  return MaterialPageRoute(
                    builder: (_) =>
                        const UnderConstructionPage(pageTitle: 'Pagamentos'),
                    settings: settings,
                  );
                case '/inventario':
                  return MaterialPageRoute(
                    builder: (_) =>
                        const UnderConstructionPage(pageTitle: 'Inventário'),
                    settings: settings,
                  );
                case '/aprovacoes':
                  return MaterialPageRoute(
                    builder: (_) =>
                        const UnderConstructionPage(pageTitle: 'Aprovações'),
                    settings: settings,
                  );
                case '/pdv':
                  return MaterialPageRoute(
                    builder: (_) =>
                        const UnderConstructionPage(pageTitle: 'PDV'),
                    settings: settings,
                  );
                case '/descontos':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'baixas',
                        child: SelecaoDescontoPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/descontos/baixa':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'baixas',
                        child: DescontoBaixaPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/descontos/venda':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'baixas',
                        child: DescontoVendaPage(),
                      ),
                    ),
                    settings: settings,
                  );
                case '/descontos/alterar-entrada':
                  return MaterialPageRoute(
                    builder: (_) => const ProtectedRoute(
                      child: PermissionGuard(
                        module: 'baixas',
                        child: AlterarEntradaPage(),
                      ),
                    ),
                    settings: settings,
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Rota não encontrada')),
                    ),
                    settings: settings,
                  );
              }
            } catch (e) {
              debugPrint('Erro na navegação: $e');
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Erro na navegação'),
                        SizedBox(height: 8),
                        Text('Tente novamente ou reinicie o app'),
                      ],
                    ),
                  ),
                ),
                settings: settings,
              );
            }
          },
        );
      },
    );
  }
}
