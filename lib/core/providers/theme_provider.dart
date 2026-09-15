import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';

/// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeService _themeService = ThemeService();
  
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }
  
  /// Load saved theme
  Future<void> _loadTheme() async {
    final savedMode = await _themeService.getThemeMode();
    state = savedMode;
  }
  
  /// Toggle theme
  Future<void> toggleTheme() async {
    final newMode = await _themeService.toggleTheme(state);
    state = newMode;
  }
  
  /// Set theme explicitly
  Future<void> setTheme(ThemeMode mode) async {
    await _themeService.saveThemeMode(mode);
    state = mode;
  }
}
