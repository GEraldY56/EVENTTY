import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Service - Manage dark mode state and persistence
class ThemeService {
  static const String _themeKey = 'isDarkMode';
  
  /// Get saved theme mode
  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_themeKey) ?? false;
      return isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      return ThemeMode.light; // Default to light
    }
  }
  
  /// Save theme mode
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    } catch (e) {
      // Ignore save error - return default theme
    }
  }
  
  /// Toggle theme mode
  Future<ThemeMode> toggleTheme(ThemeMode currentMode) async {
    final newMode = currentMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await saveThemeMode(newMode);
    return newMode;
  }
}
