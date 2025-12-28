// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../data/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  String? _token;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // --- 1. SESSION MANAGEMENT (Fixes Statelessness) ---

  Future<void> loadSession() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUser = prefs.getString('auth_user_json');

    if (storedToken != null && storedUser != null) {
      try {
        _token = storedToken;
        _currentUser = User.fromJson(jsonDecode(storedUser));
        print("✅ Session Restored: ${_currentUser?.username} ($_token)");
      } catch (e) {
        print("⚠️ Session Corrupt: Clearing storage");
        await logout();
      }
    } else {
      print("ℹ️ No active session found.");
    }
    _isInitialized = true;
  }

  Future<void> _persistSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user_json', jsonEncode(user.toJson()));

    _token = token;
    _currentUser = user;
    print("💾 Session Saved: ${user.username}");
  }

  // --- 2. AUTHENTICATION ---

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: ApiConfig.headers, // Use base headers
            body: jsonEncode({
              'username': username,
              'password': _hashPassword(password),
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        // FIX: Save ID immediately so subsequent requests work
        await _persistSession(user.id, user);
        return true;
      }
    } catch (e) {
      print("Login Error: $e");
      return _mockLogin(username);
    }
    return false;
  }

  Future<bool> signup(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.signup),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'username': username,
              'password': _hashPassword(password),
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 201) {
        final user = User.fromJson(jsonDecode(response.body));
        await _persistSession(user.id, user);
        return true;
      }
    } catch (e) {
      // Mock Fallback
      await Future.delayed(const Duration(seconds: 1));
      if (password.length >= 6) {
        final user = User(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}',
          username: username,
          displayName: username,
          avatarUrl: 'https://i.pravatar.cc/150?u=${username.length}',
          isVerified: false,
          isActivist: false,
        );
        await _persistSession(user.id, user);
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user_json');
    _currentUser = null;
    _token = null;
  }

  // --- MOCK LOGIC ---
  Future<bool> _mockLogin(String username) async {
    User mockUser;
    if (username.contains('activist')) {
      mockUser = const User(
        id: 'u_act',
        username: 'activist_pro',
        displayName: 'Community Leader',
        avatarUrl: 'https://i.pravatar.cc/150?u=act',
        isVerified: true,
        isActivist: true,
      );
    } else if (username.contains('verified')) {
      mockUser = const User(
        id: 'u_ver',
        username: 'verified_user',
        displayName: 'Verified Citizen',
        avatarUrl: 'https://i.pravatar.cc/150?u=ver',
        isVerified: true,
        isActivist: false,
      );
    } else {
      mockUser = const User(
        id: 'u_new',
        username: 'new_user',
        displayName: 'New Member',
        avatarUrl: 'https://i.pravatar.cc/150?u=new',
        isVerified: false,
        isActivist: false,
      );
    }
    await _persistSession(mockUser.id, mockUser);
    return true;
  }
}
