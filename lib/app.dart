// lib/app.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/feed_screen.dart';
import 'services/auth_service.dart';
import 'app_settings.dart';

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
            title: 'SafeSpace',
            debugShowCheckedModeBanner: false,
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
