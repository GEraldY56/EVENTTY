import 'package:flutter/material.dart';

/// App Color Palette - Sesuai Design System EVENTY
class AppColors {
  AppColors._();

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  // Primary Colors (Design System)
  static const Color primary = Color(0xFF2563EB); // #2563EB
  static const Color secondary = Color(0xFF60A5FA); // #60A5FA

  // Card & Surface
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors (Design System)
  static const Color textPrimary = Color(0xFF0F172A); // #0F172A
  static const Color textSecondary = Color(0xFF64748B); // #64748B
  static const Color textTertiary = Color(0xFF94A3B8);

  // Semantic Colors (Design System)
  static const Color success = Color(0xFF22C55E); // #22C55E
  static const Color warning = Color(0xFFF59E0B); // #F59E0B
  static const Color error = Color(0xFFEF4444); // #EF4444
  static const Color info = Color(0xFF3B82F6);

  // Status Colors
  static const Color statusOpen = Color(0xFF22C55E);
  static const Color statusOngoing = Color(0xFF3B82F6);
  static const Color statusClosed = Color(0xFF94A3B8);

  // Neutral Shades
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Shadow (Soft shadows sesuai design system)
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowHeavy = Color(0x1F000000);

  // Banner Colors (Modern gradients)
  static const Color bannerClassmeet = Color(0xFF3B82F6);
  static const Color bannerCareerDay = Color(0xFF8B5CF6);
  static const Color bannerWorkshop = Color(0xFF06B6D4);

  // Category Colors (Friendly & vibrant)
  static const Color categoryClassmeet = Color(0xFF3B82F6);
  static const Color categorySports = Color(0xFFEF4444);
  static const Color categorySeminar = Color(0xFF8B5CF6);
  static const Color categoryWorkshop = Color(0xFF06B6D4);
  static const Color categoryCareer = Color(0xFFF59E0B);
  static const Color categoryScience = Color(0xFF22C55E);
  static const Color categoryEnglish = Color(0xFFEC4899);
  static const Color categoryArt = Color(0xFFA855F7);
  static const Color categoryExtracurricular = Color(0xFF6366F1);

  // Predefined Opacity Colors
  static const Color primary10 = Color(0x1A2563EB);
  static const Color primary20 = Color(0x332563EB);
  static const Color primary30 = Color(0x4D2563EB);
  static const Color primary60 = Color(0x992563EB);
  
  static const Color secondary10 = Color(0x1A60A5FA);
  static const Color secondary20 = Color(0x3360A5FA);
  
  static const Color accent10 = Color(0x1A7C3AED);
  static const Color accent20 = Color(0x337C3AED);
  
  static const Color info10 = Color(0x1A3B82F6);
  static const Color info20 = Color(0x333B82F6);
  
  static const Color success10 = Color(0x1A22C55E);
  static const Color success20 = Color(0x3322C55E);
  
  static const Color warning10 = Color(0x1AF59E0B);
  static const Color warning20 = Color(0x33F59E0B);
  
  static const Color error10 = Color(0x1AEF4444);
  static const Color error20 = Color(0x33EF4444);

  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white90 = Color(0xE6FFFFFF);
  
  // Category colors with opacity
  static const Color categoryClassmeet10 = Color(0x1A3B82F6);
  static const Color categoryClassmeet30 = Color(0x4D3B82F6);
  static const Color categorySports10 = Color(0x1AEF4444);
  static const Color categorySeminar10 = Color(0x1A8B5CF6);
  static const Color categoryWorkshop10 = Color(0x1A06B6D4);
  static const Color categoryCareer10 = Color(0x1AF59E0B);
  static const Color categoryScience10 = Color(0x1A22C55E);
  static const Color categoryEnglish10 = Color(0x1AEC4899);
  static const Color categoryArt10 = Color(0x1AA855F7);
  static const Color categoryExtracurricular10 = Color(0x1A6366F1);
}




/// Dark Theme Colors
class AppColorsDark {
  AppColorsDark._();

  // Background & Surface (Dark)
  static const Color background = Color(0xFF0F172A); // Dark blue-gray
  static const Color surface = Color(0xFF1E293B); // Slightly lighter
  static const Color border = Color(0xFF334155); // Subtle borders

  // Primary Colors (Adjusted for dark mode)
  static const Color primary = Color(0xFF60A5FA); // Lighter blue
  static const Color secondary = Color(0xFF93C5FD); // Even lighter

  // Card & Surface
  static const Color card = Color(0xFF1E293B);

  // Text Colors (Dark mode)
  static const Color textPrimary = Color(0xFFF1F5F9); // Almost white
  static const Color textSecondary = Color(0xFFCBD5E1); // Light gray
  static const Color textTertiary = Color(0xFF94A3B8); // Medium gray

  // Semantic Colors (Same or slightly adjusted)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24); // Slightly lighter
  static const Color error = Color(0xFFF87171); // Slightly lighter
  static const Color info = Color(0xFF60A5FA);

  // Status Colors
  static const Color statusOpen = Color(0xFF22C55E);
  static const Color statusOngoing = Color(0xFF60A5FA);
  static const Color statusClosed = Color(0xFF64748B);

  // Neutral Shades (Inverted for dark)
  static const Color neutral50 = Color(0xFF1E293B);
  static const Color neutral100 = Color(0xFF334155);
  static const Color neutral200 = Color(0xFF475569);
  static const Color neutral300 = Color(0xFF64748B);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFFCBD5E1);
  static const Color neutral600 = Color(0xFFE2E8F0);
  static const Color neutral700 = Color(0xFFF1F5F9);
  static const Color neutral800 = Color(0xFFF8FAFC);
  static const Color neutral900 = Color(0xFFFFFFFF);

  // Overlay
  static const Color overlay = Color(0xCC000000); // Darker overlay
  static const Color overlayLight = Color(0x66000000);

  // Shadow (Lighter shadows for dark mode)
  static const Color shadowLight = Color(0x1AFFFFFF);
  static const Color shadowMedium = Color(0x33FFFFFF);
  static const Color shadowHeavy = Color(0x4DFFFFFF);

  // Category Colors (Keep vibrant)
  static const Color categoryClassmeet = Color(0xFF60A5FA);
  static const Color categorySports = Color(0xFFF87171);
  static const Color categorySeminar = Color(0xFFA78BFA);
  static const Color categoryWorkshop = Color(0xFF22D3EE);
  static const Color categoryCareer = Color(0xFFFBBF24);
  static const Color categoryScience = Color(0xFF4ADE80);
  static const Color categoryEnglish = Color(0xFFF472B6);
  static const Color categoryArt = Color(0xFFC084FC);
  static const Color categoryExtracurricular = Color(0xFF818CF8);
}


/// Extension for context-aware colors (supports dark mode)
extension AppColorsExtension on BuildContext {
  /// Get adaptive colors based on current theme
  AppColorsAdaptive get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return AppColorsAdaptive(isDark);
  }
}

/// Adaptive colors class that switches between light and dark
class AppColorsAdaptive {
  final bool isDark;
  
  const AppColorsAdaptive(this.isDark);
  
  // Background & Surface
  Color get background => isDark ? AppColorsDark.background : AppColors.background;
  Color get surface => isDark ? AppColorsDark.surface : AppColors.surface;
  Color get border => isDark ? AppColorsDark.border : AppColors.border;
  Color get card => isDark ? AppColorsDark.card : AppColors.card;
  
  // Primary Colors
  Color get primary => isDark ? AppColorsDark.primary : AppColors.primary;
  Color get secondary => isDark ? AppColorsDark.secondary : AppColors.secondary;
  
  // Text Colors
  Color get textPrimary => isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
  Color get textSecondary => isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
  Color get textTertiary => isDark ? AppColorsDark.textTertiary : AppColors.textTertiary;
  
  // Semantic Colors
  Color get success => isDark ? AppColorsDark.success : AppColors.success;
  Color get warning => isDark ? AppColorsDark.warning : AppColors.warning;
  Color get error => isDark ? AppColorsDark.error : AppColors.error;
  Color get info => isDark ? AppColorsDark.info : AppColors.info;
  
  // Status Colors
  Color get statusOpen => isDark ? AppColorsDark.statusOpen : AppColors.statusOpen;
  Color get statusOngoing => isDark ? AppColorsDark.statusOngoing : AppColors.statusOngoing;
  Color get statusClosed => isDark ? AppColorsDark.statusClosed : AppColors.statusClosed;
  
  // Neutral Shades
  Color get neutral50 => isDark ? AppColorsDark.neutral50 : AppColors.neutral50;
  Color get neutral100 => isDark ? AppColorsDark.neutral100 : AppColors.neutral100;
  Color get neutral200 => isDark ? AppColorsDark.neutral200 : AppColors.neutral200;
  Color get neutral300 => isDark ? AppColorsDark.neutral300 : AppColors.neutral300;
  Color get neutral400 => isDark ? AppColorsDark.neutral400 : AppColors.neutral400;
  Color get neutral500 => isDark ? AppColorsDark.neutral500 : AppColors.neutral500;
  Color get neutral600 => isDark ? AppColorsDark.neutral600 : AppColors.neutral600;
  Color get neutral700 => isDark ? AppColorsDark.neutral700 : AppColors.neutral700;
  Color get neutral800 => isDark ? AppColorsDark.neutral800 : AppColors.neutral800;
  Color get neutral900 => isDark ? AppColorsDark.neutral900 : AppColors.neutral900;
  
  // Category Colors (same for both themes for consistency)
  Color get categoryClassmeet => AppColors.categoryClassmeet;
  Color get categorySports => AppColors.categorySports;
  Color get categorySeminar => AppColors.categorySeminar;
  Color get categoryWorkshop => AppColors.categoryWorkshop;
  Color get categoryCareer => AppColors.categoryCareer;
  Color get categoryScience => AppColors.categoryScience;
}
