import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _mail = '';
  String? _profileImagePath;

  String get name => _name;
  String get mail => _mail;
  String? get profileImagePath => _profileImagePath;

  UserProvider() {
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    _profileImagePath = prefs.getString('user_profile_image');
    notifyListeners();
  }

  Future<void> setProfileImage(String path) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_image', path);
    notifyListeners();
  }

  void setUserInfo(String name, String mail) {
    _name = name;
    _mail = mail;
    notifyListeners();
  }

  void setUserInfoFromJson(Map<String, dynamic> json) {
    // Se o backend retornar 'apelido', usamos ele como nome principal para a Home
    final apelido = (json['apelido'] ?? '').toString().trim();
    final nome = (json['nome'] ?? '').toString().trim();

    _name = apelido.isNotEmpty ? apelido : nome;
    _mail = (json['email'] ?? '').toString().trim();
    notifyListeners();
  }

  void clearUser() {
    _name = '';
    _mail = '';
    _profileImagePath = null;
    notifyListeners();
  }
}
