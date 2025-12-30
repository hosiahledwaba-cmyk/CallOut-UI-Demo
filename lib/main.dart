// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'app.dart';
import 'services/auth_service.dart';
import 'services/media_service.dart';
import 'state/app_state_notifier.dart'; // Import Notifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().loadSession();
  MediaService().cleanOldCache();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Wrap App in Provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateNotifier(),
      child: const SafeSpaceApp(),
    ),
  );
}
