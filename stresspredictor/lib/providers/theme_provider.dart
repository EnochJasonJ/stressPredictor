import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System Default';
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    
    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    switch (themeName) {
      case 'Light':
        _themeMode = ThemeMode.light;
        await prefs.setString('theme_mode', 'light');
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        await prefs.setString('theme_mode', 'dark');
        break;
      case 'System Default':
      default:
        _themeMode = ThemeMode.system;
        await prefs.setString('theme_mode', 'system');
        break;
    }
    notifyListeners();
  }
}
