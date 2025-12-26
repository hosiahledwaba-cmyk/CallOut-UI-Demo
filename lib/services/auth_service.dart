// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../data/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // --- API + MOCK LOGIN ---
  Future<bool> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: ApiConfig.headers,
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(jsonDecode(response.body));
        return true;
      }
    } catch (e) {
      // API Failed/Timeout -> Use Mock Fallback
      return _mockLogin(username);
    }
    return false;
  }

  // --- API + MOCK SIGNUP ---
  Future<bool> signup(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.signup),
            headers: ApiConfig.headers,
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201) {
        _currentUser = User.fromJson(jsonDecode(response.body));
        return true;
      }
    } catch (e) {
      // API Failed/Timeout -> Use Mock Fallback
      await Future.delayed(const Duration(seconds: 1)); // Sim delay
      _currentUser = User(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        displayName: username,
        avatarUrl: 'https://i.pravatar.cc/150?u=${username.length}',
        isVerified: false,
        isActivist: false,
      );
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }

  // --- MOCK LOGIC ---
  bool _mockLogin(String username) {
    if (username.contains('activist')) {
      _currentUser = const User(
        id: 'u_act',
        username: 'activist_pro',
        displayName: 'Community Leader',
        avatarUrl: 'https://i.pravatar.cc/150?u=act',
        isVerified: true,
        isActivist: true,
      );
      return true;
    }
    if (username.contains('verified')) {
      _currentUser = const User(
        id: 'u_ver',
        username: 'verified_user',
        displayName: 'Verified Citizen',
        avatarUrl: 'https://i.pravatar.cc/150?u=ver',
        isVerified: true,
        isActivist: false,
      );
      return true;
    }
    // Default New User
    _currentUser = const User(
      id: 'u_new',
      username: 'new_user',
      displayName: 'New Member',
      avatarUrl: 'https://i.pravatar.cc/150?u=new',
      isVerified: false,
      isActivist: false,
    );
    return true;
  }
}
