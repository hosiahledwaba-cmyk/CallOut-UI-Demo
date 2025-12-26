// lib/services/verification_service.dart
import 'dart:async';

class VerificationService {
  // Mock singleton
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  // Simulation State
  bool _hasEmailVerified = false;
  bool _hasPhoneVerified = false;
  bool _hasIdVerified = false;

  bool get isStandardVerified => _hasEmailVerified || _hasPhoneVerified;
  bool get isActivistReady =>
      _hasEmailVerified && _hasPhoneVerified && _hasIdVerified;

  // --- EMAIL ---
  Future<bool> sendEmailOtp(String email) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API
    return true; // Always succeeds for demo
  }

  Future<bool> verifyEmailOtp(String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == "1234") {
      _hasEmailVerified = true;
      return true;
    }
    return false;
  }

  // --- PHONE ---
  Future<bool> sendPhoneOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<bool> verifyPhoneOtp(String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == "1234") {
      _hasPhoneVerified = true;
      return true;
    }
    return false;
  }

  // --- GOVERNMENT ID ---
  Future<bool> submitIdentityAudit({
    required String fullName,
    required String idNumber,
  }) async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Simulate Government DB check
    // Mock Validation: ID must be 13 chars (standard SA ID length)
    if (idNumber.length == 13 && fullName.contains(" ")) {
      _hasIdVerified = true;
      return true;
    }
    return false;
  }

  // Reset for testing
  void reset() {
    _hasEmailVerified = false;
    _hasPhoneVerified = false;
    _hasIdVerified = false;
  }
}
