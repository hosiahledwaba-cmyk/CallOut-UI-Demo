// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for Platform check
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import for Token Cleanup
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

  // Helper for Protected Endpoints
  Map<String, String> get _authHeaders {
    return {...ApiConfig.headers, 'Authorization': 'Bearer $_token'};
  }

  // --- 1. SESSION MANAGEMENT ---

  Future<void> loadSession() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    final storedUser = prefs.getString('auth_user_json');

    if (storedToken != null && storedUser != null) {
      try {
        _token = storedToken;
        _currentUser = User.fromJson(jsonDecode(storedUser));
        print("✅ Session Restored: ${_currentUser?.username}");
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
            headers: ApiConfig.headers,
            body: jsonEncode({
              'username': username,
              'password': _hashPassword(password),
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        await _persistSession(user.id, user);

        // RE-INIT PUSH: Ensure token is sent for this specific user after login
        _refreshDeviceToken();

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

        // RE-INIT PUSH
        _refreshDeviceToken();

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

  // --- 3. CLEANUP (Updated for Notifications) ---

  Future<void> logout() async {
    // 1. Tell Backend to remove this device token
    // This ensures you don't get notifications for the old user
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && _token != null) {
        print("🔌 Removing Device Token...");
        await http.delete(
          // Assuming ApiConfig has baseUrl. If not, replace with hardcoded string
          Uri.parse("${ApiConfig.baseUrl}/users/me/device-token"),
          headers: _authHeaders,
          body: jsonEncode({
            "token": fcmToken,
            "platform": Platform.isAndroid ? "android" : "ios",
          }),
        );
      }
    } catch (e) {
      print("⚠️ Log out cleanup error (Token might already be gone): $e");
    }

    // 2. Clear Local Storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user_json');
    _currentUser = null;
    _token = null;
    print("👋 Logged out successfully");
  }

  // Helper to re-send token after login (Just in case)
  void _refreshDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await http.post(
          Uri.parse("${ApiConfig.baseUrl}/users/me/device-token"),
          headers: _authHeaders,
          body: jsonEncode({
            "token": token,
            "platform": Platform.isAndroid ? "android" : "ios",
          }),
        );
      }
    } catch (e) {
      print("Token Refresh Warning: $e");
    }
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
