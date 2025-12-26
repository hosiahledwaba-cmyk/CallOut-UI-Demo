// lib/screens/verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/glass_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/top_nav.dart';
import '../theme/design_tokens.dart';
import '../services/verification_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final VerificationService _service = VerificationService();
  final PageController _pageController = PageController();

  // Controllers
  final _emailController = TextEditingController();
  final _emailOtpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  // UI State
  int _currentStep = 0;
  bool _isLoading = false;
  bool _emailSent = false;
  bool _phoneSent = false;

  // Success States
  bool _emailVerified = false;
  bool _phoneVerified = false;
  bool _idVerified = false;

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? DesignTokens.accentAlert
            : DesignTokens.accentSafe,
      ),
    );
  }

  // --- LOGIC: EMAIL ---
  Future<void> _handleEmailSend() async {
    setState(() => _isLoading = true);
    await _service.sendEmailOtp(_emailController.text);
    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
    _showSnack("OTP sent to ${_emailController.text} (Use 1234)");
  }

  Future<void> _handleEmailVerify() async {
    setState(() => _isLoading = true);
    final success = await _service.verifyEmailOtp(_emailOtpController.text);
    setState(() {
      _isLoading = false;
      _emailVerified = success;
    });
    if (success)
      _showSnack("Email Verified Successfully");
    else
      _showSnack("Invalid OTP", isError: true);
  }

  // --- LOGIC: PHONE ---
  Future<void> _handlePhoneSend() async {
    setState(() => _isLoading = true);
    await _service.sendPhoneOtp(_phoneController.text);
    setState(() {
      _isLoading = false;
      _phoneSent = true;
    });
    _showSnack("OTP sent to ${_phoneController.text} (Use 1234)");
  }

  Future<void> _handlePhoneVerify() async {
    setState(() => _isLoading = true);
    final success = await _service.verifyPhoneOtp(_phoneOtpController.text);
    setState(() {
      _isLoading = false;
      _phoneVerified = success;
    });
    if (success)
      _showSnack("Phone Verified Successfully");
    else
      _showSnack("Invalid OTP", isError: true);
  }

  // --- LOGIC: ID AUDIT ---
  Future<void> _handleIdentitySubmit() async {
    setState(() => _isLoading = true);
    final success = await _service.submitIdentityAudit(
      fullName: _nameController.text,
      idNumber: _idController.text,
    );
    setState(() {
      _isLoading = false;
      _idVerified = success;
    });

    if (success) {
      _showSnack("Identity Audit Passed. You are now an Activist.");
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true); // Return success to profile
    } else {
      _showSnack(
        "Audit Failed. Ensure ID is valid (13 digits).",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          const TopNav(title: "Verification Center", showBack: true),

          // Progress Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, "Contact"),
                _buildConnector(0),
                _buildStepIndicator(1, "Identity"),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // Manual navigation only
              children: [_buildContactStep(), _buildIdentityStep()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep() {
    // To become Verified, need ONE. To proceed to Activist, need BOTH.
    final bool canProceed = _emailVerified && _phoneVerified;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 1: Contact Verification",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "To be a Verified User, verify either method.\nTo become an Activist, you must verify BOTH.",
            style: TextStyle(color: DesignTokens.textSecondary),
          ),
          const SizedBox(height: 24),

          // --- EMAIL SECTION ---
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.email, color: DesignTokens.accentPrimary),
                    const SizedBox(width: 8),
                    const Text(
                      "Email Address",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (_emailVerified)
                      const Icon(
                        Icons.check_circle,
                        color: DesignTokens.accentSafe,
                      ),
                  ],
                ),
                if (!_emailVerified) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          hint: "name@example.com",
                          icon: Icons.alternate_email,
                          controller: _emailController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!_emailSent)
                        GlassButton(
                          label: "Send",
                          onTap: _handleEmailSend,
                          isPrimary: true,
                        ),
                    ],
                  ),
                  if (_emailSent) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GlassTextField(
                            hint: "1234",
                            icon: Icons.pin,
                            controller: _emailOtpController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassButton(
                          label: "Verify",
                          onTap: _handleEmailVerify,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ],
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Verified",
                      style: TextStyle(color: DesignTokens.accentSafe),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- PHONE SECTION ---
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.phone_android,
                      color: DesignTokens.accentPrimary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Mobile Number",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (_phoneVerified)
                      const Icon(
                        Icons.check_circle,
                        color: DesignTokens.accentSafe,
                      ),
                  ],
                ),
                if (!_phoneVerified) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          hint: "+27 12 345 6789",
                          icon: Icons.phone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!_phoneSent)
                        GlassButton(
                          label: "Send",
                          onTap: _handlePhoneSend,
                          isPrimary: true,
                        ),
                    ],
                  ),
                  if (_phoneSent) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GlassTextField(
                            hint: "1234",
                            icon: Icons.pin,
                            controller: _phoneOtpController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassButton(
                          label: "Verify",
                          onTap: _handlePhoneVerify,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ],
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Verified",
                      style: TextStyle(color: DesignTokens.accentSafe),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (canProceed)
            GlassButton(
              label: "Continue to Activist Audit",
              icon: Icons.arrow_forward,
              onTap: () => _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            )
          else if (_emailVerified || _phoneVerified)
            GlassButton(
              label: "Finish as Standard Verified User",
              icon: Icons.check,
              isPrimary: false,
              onTap: () => Navigator.pop(context, true),
            ),
        ],
      ),
    );
  }

  Widget _buildIdentityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 2: Activist Clearance",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "This information is checked against government databases to ensure accountability.",
            style: TextStyle(color: DesignTokens.textSecondary),
          ),
          const SizedBox(height: 24),

          GlassCard(
            child: Column(
              children: [
                GlassTextField(
                  hint: "Full Legal Name",
                  icon: Icons.badge,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  hint: "ID / Passport Number",
                  icon: Icons.fingerprint,
                  controller: _idController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignTokens.accentAlert.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: DesignTokens.accentAlert.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: DesignTokens.accentAlert,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Your ID is encrypted and only used for a one-time audit.",
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GlassButton(
              label: "Submit for Audit",
              icon: Icons.verified_user,
              onTap: _handleIdentitySubmit,
            ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text("Back"),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildStepIndicator(int stepIndex, String label) {
    final bool isActive = _currentStep >= stepIndex;
    // We infer active step from page controller visually or state
    // For simplicity, lets assume Step 0 is active if on page 0
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: DesignTokens.glassWhite.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: DesignTokens.accentPrimary),
          ),
          child: Center(
            child: Text(
              "${stepIndex + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildConnector(int index) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      color: DesignTokens.glassBorder,
    );
  }
}
