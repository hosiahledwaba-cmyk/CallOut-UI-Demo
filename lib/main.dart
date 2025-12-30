// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/media_service.dart';
import 'services/deep_link_service.dart';
import 'state/app_state_notifier.dart';
import 'state/notification_state.dart';
import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase (Required for App Functionality)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    PushNotificationService().initialize();
  } catch (e) {
    print("⚠️ Firebase Init Error: $e");
  }

  // 2. Standard App Initialization
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AuthService().loadSession();
  MediaService().cleanOldCache();
  DeepLinkService().init(navigatorKey);

  // 3. Run App (Theme is handled inside App & GlassScaffold now)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
        ChangeNotifierProvider(create: (_) => NotificationState()),
      ],
      child: const SafeSpaceApp(),
    ),
  );
}
