import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _name;
  String? _email;
  bool _isLoading = true;

  String? get token => _token;
  String? get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _name = prefs.getString('name');
    _email = prefs.getString('email');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) prefs.setString('token', _token!);
    if (_userId != null) prefs.setString('userId', _userId!);
    if (_name != null) prefs.setString('name', _name!);
    if (_email != null) prefs.setString('email', _email!);
  }

  Future<void> register(
      String name, String email, String password, String phone) async {
    final data = await AuthService.register(name, email, password, phone);
    _token = data['access_token'];
    _userId = data['user_id'];
    _name = data['name'];
    _email = data['email'];
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await AuthService.login(email, password);
    _token = data['access_token'];
    _userId = data['user_id'];
    _name = data['name'];
    _email = data['email'];
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _name = null;
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
