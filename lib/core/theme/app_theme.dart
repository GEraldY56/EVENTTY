import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// App Theme Data - Light and Dark themes
class AppTheme {
  AppTheme._();

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.background,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.heading3.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      
      // Card
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primary10,
        disabledColor: AppColors.neutral100,
        labelStyle: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Dialog
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTextStyles.body1.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        bodySmall: AppTextStyles.captionSmall.copyWith(color: AppColors.textTertiary),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColorsDark.primary,
        secondary: AppColorsDark.secondary,
        surface: AppColorsDark.surface,
        error: AppColorsDark.error,
        onPrimary: AppColorsDark.textPrimary,
        onSecondary: AppColorsDark.textPrimary,
        onSurface: AppColorsDark.textPrimary,
        onError: AppColorsDark.textPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColorsDark.background,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.card,
        foregroundColor: AppColorsDark.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.heading3.copyWith(
          color: AppColorsDark.textPrimary,
        ),
      ),
      
      // Card
      cardTheme: const CardThemeData(
        color: AppColorsDark.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColorsDark.border, width: 1),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsDark.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: AppColorsDark.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColorsDark.textSecondary,
        size: 24,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColorsDark.border,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.card,
        selectedItemColor: AppColorsDark.primary,
        unselectedItemColor: AppColorsDark.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsDark.neutral100,
        selectedColor: Color(0x1A60A5FA), // primary10 for dark
        disabledColor: AppColorsDark.neutral100,
        labelStyle: AppTextStyles.body2.copyWith(color: AppColorsDark.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Dialog
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColorsDark.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsDark.neutral200,
        contentTextStyle: AppTextStyles.body1.copyWith(color: AppColorsDark.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(color: AppColorsDark.textPrimary),
        displayMedium: AppTextStyles.heading2.copyWith(color: AppColorsDark.textPrimary),
        displaySmall: AppTextStyles.heading3.copyWith(color: AppColorsDark.textPrimary),
        headlineMedium: AppTextStyles.titleMedium.copyWith(color: AppColorsDark.textPrimary),
        headlineSmall: AppTextStyles.titleMedium.copyWith(color: AppColorsDark.textPrimary),
        titleLarge: AppTextStyles.titleMedium.copyWith(color: AppColorsDark.textPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColorsDark.textPrimary),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColorsDark.textPrimary),
        bodyLarge: AppTextStyles.body1.copyWith(color: AppColorsDark.textPrimary),
        bodyMedium: AppTextStyles.body2.copyWith(color: AppColorsDark.textSecondary),
        bodySmall: AppTextStyles.captionSmall.copyWith(color: AppColorsDark.textTertiary),
        labelLarge: AppTextStyles.button.copyWith(color: AppColorsDark.textPrimary),
      ),
    );
  }
}
