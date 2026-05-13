import 'package:flutter/material.dart';

class AppColors {
  // Cores principais do tema Cometa
  static const Color primary = Color(0xFFD32F2F); // Vermelho principal (mudança)
  static const Color primaryDark = Color(0xFFB71C1C); // Vermelho escuro
  static const Color primaryLight = Color(0xFFEF5350); // Vermelho claro
  
  // Cores secundárias
  static const Color secondary = Color(0xFF4CAF50); // Verde para ações positivas
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);
  
  // Cores de status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Cores neutras
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF212121);
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF212121); // Texto principal
  static const Color textSecondary = Color(0xFF757575); // Texto secundário
  
  // Cores para modo escuro
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );
}