// lib/services/auth_service.dart
import 'dart:async';
import '../models/user.dart';

class AuthService {
  // Mock singleton for simplicity
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Simulate API Login
  Future<bool> login(String email, String password) async {
    // TODO: Wire to real API Endpoint
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (email.isNotEmpty && password.length > 3) {
      _currentUser = const User(
        id: 'me',
        username: 'current_user',
        displayName: 'Demo User',
        avatarUrl: 'https://i.pravatar.cc/150?u=99',
      );
      return true;
    }
    return false;
  }

  // Simulate API Signup
  Future<bool> signup(String name, String email, String password) async {
    // TODO: Wire to real API Endpoint
    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && password.length > 3) {
      _currentUser = User(
        id: 'me',
        username: name.toLowerCase().replaceAll(' ', '_'),
        displayName: name,
        avatarUrl: 'https://i.pravatar.cc/150?u=99',
      );
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
  }
}
