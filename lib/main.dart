// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/auth_service.dart'; // Import to access loadSession

void main() async {
  // 1. Ensure Flutter bindings are ready for async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the User Session from storage
  // This pulls the token from disk so the API knows who you are immediately.
  await AuthService().loadSession();

  // 3. Lock Orientation (Optional, but good for stability)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 4. Start the App
  runApp(const SafeSpaceApp());
}
