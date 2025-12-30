// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- IMPORT THIS
import 'firebase_options.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/media_service.dart';
import 'services/deep_link_service.dart';
import 'services/push_notification_service.dart';
import 'services/realtime_service.dart';
import 'state/app_state_notifier.dart';
import 'state/notification_state.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🌙 Background Message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // --- FIX: SHADOW LOGIN ---
    // This connects the app to Firebase so Firestore Streams can open.
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print("👻 Signed into Firebase Anonymously");
    }
    // -------------------------

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await PushNotificationService().initialize();
  } catch (e) {
    print("⚠️ Firebase Init Error: $e");
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AuthService().loadSession();

  if (AuthService().isAuthenticated) {
    RealtimeService().init();
  }

  MediaService().cleanOldCache();
  DeepLinkService().init(navigatorKey);

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
