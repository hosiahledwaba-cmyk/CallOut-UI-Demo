// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart'; // Imports 'navigatorKey' from here
import 'services/auth_service.dart';
import 'services/media_service.dart';
import 'services/deep_link_service.dart';
import 'state/app_state_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().loadSession();
  MediaService().cleanOldCache();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Deep Linking with the key from app.dart
  DeepLinkService().init(navigatorKey);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateNotifier(),
      child: const SafeSpaceApp(),
    ),
  );
}
