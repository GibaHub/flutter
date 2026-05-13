import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/installment_repository_impl.dart';
import 'data/repositories/news_repository_impl.dart';
import 'presentation/controllers/installment_controller.dart';
import 'presentation/screens/financial/installment_list_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/web_admin/news_form_screen.dart';
import 'presentation/screens/web_admin/admin_dashboard_screen.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/controllers/news_controller.dart';
import 'presentation/controllers/home_controller.dart';
import 'data/services/sync_service.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() {
  runApp(const CredCometaApp());
}

class CredCometaApp extends StatelessWidget {
  const CredCometaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => Dio()),
        Provider<SyncService>(create: (_) => SyncService()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProxyProvider<SyncService, HomeController>(
          create: (context) => HomeController(context.read<SyncService>()),
          update: (_, syncService, controller) => HomeController(syncService),
        ),
        ProxyProvider<Dio, NewsRepositoryImpl>(
          update: (_, dio, __) => NewsRepositoryImpl(dio),
        ),
        ChangeNotifierProxyProvider<NewsRepositoryImpl, NewsController>(
          create:
              (context) => NewsController(context.read<NewsRepositoryImpl>()),
          update: (_, repo, controller) => NewsController(repo),
        ),
        ProxyProvider<Dio, InstallmentRepositoryImpl>(
          update: (_, dio, __) => InstallmentRepositoryImpl(dio),
        ),
        ChangeNotifierProxyProvider<
          InstallmentRepositoryImpl,
          InstallmentController
        >(
          create:
              (context) => InstallmentController(
                context.read<InstallmentRepositoryImpl>(),
              ),
          update:
              (_, repository, controller) => InstallmentController(repository),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Cred Cometa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR')],
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/financial': (context) => const InstallmentListScreen(),
              '/admin/dashboard': (context) => const AdminDashboardScreen(),
              '/admin/news': (context) => const NewsFormScreen(),
            },
          );
        },
      ),
    );
  }
}
