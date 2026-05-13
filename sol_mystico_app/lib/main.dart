import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router.dart';

void main() {
  runApp(const SolMysticoApp());
}

class SolMysticoApp extends StatelessWidget {
  const SolMysticoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sol Mystico',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A), // Slate 900
          background: const Color(0xFF020617), // Slate 950
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
