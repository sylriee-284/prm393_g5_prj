import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color tabInactive = Color(0xFFBDBDBD);
  static const Color navInactive = Color(0xFFB0B0B0);
  static const Color divider = Color(0xFFF2F2F2);
  static const Color accent = Color(0xFF222222);

  static const Color darkBackground = Color(0xFF121214);
  static const Color darkSurface = Color(0xFF1C1C20);
  static const Color darkTextPrimary = Color(0xFFF4F4F5);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkDivider = Color(0xFF27272A);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamilyFallback: const ['Roboto', 'Noto Sans', 'Segoe UI', 'Arial', 'sans-serif'],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: divider,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamilyFallback: const ['Roboto', 'Noto Sans', 'Segoe UI', 'Arial', 'sans-serif'],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),
      cardColor: darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: darkDivider,
    );
  }
}
