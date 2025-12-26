// lib/services/auth_service.dart
import 'dart:async';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // --- 3 DEFAULT TEST USERS ---

  // 1. New User: Unverified, Cannot Post
  static const User _testUserNew = User(
    id: 'u_new',
    username: 'new_user',
    displayName: 'New Member',
    avatarUrl: 'https://i.pravatar.cc/150?u=new',
    isVerified: false,
    isActivist: false,
  );

  // 2. Verified User: Identity Verified, Cannot Post (Consumer only)
  static const User _testUserVerified = User(
    id: 'u_verified',
    username: 'verified_user',
    displayName: 'Verified Citizen',
    avatarUrl: 'https://i.pravatar.cc/150?u=ver',
    isVerified: true,
    isActivist: false,
  );

  // 3. Activist: Verified & Can Post (Content Creator)
  static const User _testUserActivist = User(
    id: 'u_activist',
    username: 'activist_pro',
    displayName: 'Community Leader',
    avatarUrl: 'https://i.pravatar.cc/150?u=act',
    isVerified: true,
    isActivist: true,
  );

  Future<bool> login(String username, String password) async {
    // TODO: Wire to real API
    await Future.delayed(const Duration(seconds: 1));

    // Mock Login Logic for Testing
    if (username == 'new' || username == 'new_user') {
      _currentUser = _testUserNew;
      return true;
    }
    if (username == 'verified' || username == 'verified_user') {
      _currentUser = _testUserVerified;
      return true;
    }
    if (username == 'activist' || username == 'activist_pro') {
      _currentUser = _testUserActivist;
      return true;
    }

    // Default fallback if typing random stuff (Treat as New User)
    if (username.isNotEmpty && password.length > 3) {
      _currentUser = _testUserNew;
      return true;
    }

    return false;
  }

  // Updated Signup: Username & Password ONLY
  Future<bool> signup(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (username.isNotEmpty && password.length > 3) {
      // New signups are always "New Users" (Not Verified, Not Activists)
      _currentUser = User(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        displayName: username, // Display name defaults to username initially
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
}
