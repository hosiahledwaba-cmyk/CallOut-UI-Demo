// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/media_service.dart'; // Ensure this import exists

void main() async {
  // 1. Ensure Flutter bindings are ready for async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the User Session from storage
  await AuthService().loadSession();

  // 3. MEDIA STRATEGY: Background Cleanup
  // Garbage collect processed media files older than 2 days
  // We do not await this; it runs in the background.
  MediaService().cleanOldCache();

  // 4. Lock Orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 5. Start the App
  runApp(const SafeSpaceApp());
}
