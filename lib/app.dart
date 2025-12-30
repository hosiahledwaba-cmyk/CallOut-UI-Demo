// lib/app.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'services/auth_service.dart';
import 'app_settings.dart';

// GLOBAL NAVIGATOR KEY
// This is accessed by main.dart (to init DeepLinkService)
// and assigned to MaterialApp below.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SafeSpaceApp extends StatefulWidget {
  const SafeSpaceApp({super.key});

  @override
  State<SafeSpaceApp> createState() => _SafeSpaceAppState();
}

class _SafeSpaceAppState extends State<SafeSpaceApp> {
  final AppSettings _settings = AppSettings();

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
            // 1. ASSIGN GLOBAL KEY (Crucial for Deep Linking)
            navigatorKey: navigatorKey,

            title: 'SafeSpace',
            debugShowCheckedModeBanner: false,

            // 2. THEME CONFIGURATION
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _settings.effectiveThemeMode,

            // 3. AUTH ROUTING
            home: isLoggedIn ? const FeedScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
