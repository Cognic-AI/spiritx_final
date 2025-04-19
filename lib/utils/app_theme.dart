import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF26A69A);
  static const Color accentColor = Color(0xFFFFB74D);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  // Background colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);

  // Error colors
  static const Color errorColor = Color(0xFFE53935);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryDark,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
        displaySmall:
            TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
        headlineMedium:
            TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600),
        headlineSmall:
            TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600),
        titleLarge:
            TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimaryLight),
        bodyMedium: TextStyle(color: textSecondaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: textPrimaryDark,
        showSelectedLabels: true,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryLight,
      ),
      tabBarTheme: const TabBarTheme(
          labelColor: textPrimaryDark,
          unselectedLabelColor: textPrimaryLight,
          indicatorSize: TabBarIndicatorSize.label));

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: backgroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: textPrimaryDark,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
      displayMedium:
          TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
      displaySmall:
          TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w600),
      titleLarge:
          TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimaryDark),
      bodyMedium: TextStyle(color: textSecondaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
