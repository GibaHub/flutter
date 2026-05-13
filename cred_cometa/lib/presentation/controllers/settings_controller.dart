import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isBiometricsEnabled = false;

  ThemeMode get themeMode => _themeMode;
  bool get isBiometricsEnabled => _isBiometricsEnabled;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleBiometrics(bool isEnabled) {
    _isBiometricsEnabled = isEnabled;
    notifyListeners();
  }
}
