// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'services/auth_service.dart';
import 'app_settings.dart';
import 'state/notification_state.dart';
import 'widgets/in_app_notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SafeSpaceApp extends StatefulWidget {
  const SafeSpaceApp({super.key});

  @override
  State<SafeSpaceApp> createState() => _SafeSpaceAppState();
}

class _SafeSpaceAppState extends State<SafeSpaceApp> {
  final AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    // Keep the listener for the Toast popup, it's independent of UI theme
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (mounted) context.read<NotificationState>().refresh();
        if (navigatorKey.currentContext != null) {
          InAppNotificationOverlay.show(
            navigatorKey.currentContext!,
            title: message.notification!.title ?? "New Notification",
            message: message.notification!.body ?? "",
            onTap: () {},
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthService().isAuthenticated;

    return AppSettingsProvider(
      notifier: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (_, __) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'SafeSpace',
            debugShowCheckedModeBanner: false,

            // RESTORED: Respects your AppSettings (Light/Dark/System)
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _settings.effectiveThemeMode,

            home: isLoggedIn ? const FeedScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
