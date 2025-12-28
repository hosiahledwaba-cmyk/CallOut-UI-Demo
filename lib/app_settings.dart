// lib/app_settings.dart
import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  // By default: follow system theme
  bool _useSystemTheme = true;
  // When _useSystemTheme == false, this controls the forced theme
  bool _isDarkMode = false;

  bool _reduceTransparency = false;
  bool _reduceMotion = false;

  // getters
  bool get useSystemTheme => _useSystemTheme;
  bool get isDarkMode => _isDarkMode;
  bool get reduceTransparency => _reduceTransparency;
  bool get reduceMotion => _reduceMotion;

  ThemeMode get effectiveThemeMode {
    if (_useSystemTheme) return ThemeMode.system;
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // toggles
  void toggleUseSystemTheme(bool val) {
    _useSystemTheme = val;
    notifyListeners();
  }

  void toggleDarkMode(bool val) {
    _isDarkMode = val;
    // disable system override if user explicitly sets a theme
    _useSystemTheme = false;
    notifyListeners();
  }

  void toggleTransparency(bool val) {
    _reduceTransparency = val;
    notifyListeners();
  }

  void toggleMotion(bool val) {
    _reduceMotion = val;
    notifyListeners();
  }

  // convenience to set both at once (if needed)
  void setThemeOverride({required bool dark, required bool override}) {
    _isDarkMode = dark;
    _useSystemTheme = !override;
    notifyListeners();
  }
}

// Inherited wrapper so callers can do AppSettingsProvider.of(context)
class AppSettingsProvider extends InheritedNotifier<AppSettings> {
  const AppSettingsProvider({
    super.key,
    required AppSettings notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppSettings? of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AppSettingsProvider>();
    return provider?.notifier;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<AppSettings> oldWidget) {
    return true;
  }
}
