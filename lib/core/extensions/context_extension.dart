import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Theme colors extension for easy access
class ThemeColors {
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color surface;

  const ThemeColors({
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.surface,
  });
}

/// BuildContext Extensions
extension ContextExtension on BuildContext {
  /// Get theme colors
  ThemeColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return ThemeColors(
      card: AppColors.card,
      border: AppColors.border,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textTertiary: AppColors.textTertiary,
      surface: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
    );
  }
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get keyboard height
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Show snackbar
  void showSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
