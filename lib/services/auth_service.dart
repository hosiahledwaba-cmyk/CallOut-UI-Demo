// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // Requires: crypto: ^3.0.0 in pubspec.yaml
import '../models/user.dart';
import '../data/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // --- HELPER: HASH PASSWORD ---
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // --- API + MOCK LOGIN ---
  Future<bool> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'username': username,
              'password': _hashPassword(password), // Send Hash, not Cleartext
            }),
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
            body: jsonEncode({
              'username': username,
              'password': _hashPassword(password), // Send Hash
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201) {
        _currentUser = User.fromJson(jsonDecode(response.body));
        return true;
      } else {
        // Log error if needed, e.g., print(response.body);
        return false;
      }
    } catch (e) {
      // API Failed/Timeout -> Use Mock Fallback
      await Future.delayed(const Duration(seconds: 1)); // Sim delay

      // Allow signup fallback if valid length (Mock logic)
      if (password.length >= 6) {
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
  }

  void logout() {
    _currentUser = null;
  }

  // --- MOCK LOGIC ---
  bool _mockLogin(String username) {
    // 3 Test Personas
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
