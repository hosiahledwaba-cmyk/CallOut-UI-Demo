// lib/app.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

// Simple InheritedWidget to manage simulation settings globally
class AppSettingsProvider extends InheritedWidget {
  final bool reduceMotion;
  final bool reduceTransparency;
  final Function(bool) toggleMotion;
  final Function(bool) toggleTransparency;

  const AppSettingsProvider({
    super.key,
    required super.child,
    required this.reduceMotion,
    required this.reduceTransparency,
    required this.toggleMotion,
    required this.toggleTransparency,
  });

  static AppSettingsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSettingsProvider>();
  }

  @override
  bool updateShouldNotify(AppSettingsProvider oldWidget) {
    return reduceMotion != oldWidget.reduceMotion ||
        reduceTransparency != oldWidget.reduceTransparency;
  }
}

class SafeSpaceApp extends StatefulWidget {
  const SafeSpaceApp({super.key});

  @override
  State<SafeSpaceApp> createState() => _SafeSpaceAppState();
}

class _SafeSpaceAppState extends State<SafeSpaceApp> {
  bool _reduceMotion = false;
  bool _reduceTransparency = false;

  void _toggleMotion(bool value) => setState(() => _reduceMotion = value);
  void _toggleTransparency(bool value) =>
      setState(() => _reduceTransparency = value);

  @override
  Widget build(BuildContext context) {
    return AppSettingsProvider(
      reduceMotion: _reduceMotion,
      reduceTransparency: _reduceTransparency,
      toggleMotion: _toggleMotion,
      toggleTransparency: _toggleTransparency,
      child: MaterialApp(
        title: 'SafeSpace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(), // Start at Login
      ),
    );
  }
}
