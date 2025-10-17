import "package:flutter/material.dart";

class ForemanColors {
  static const teal    = Color(0xFF00C5D1); // Primary
  static const navy    = Color(0xFF0C1B30); // Background
  static const white   = Color(0xFFFFFFFF);
  static const green   = Color(0xFF00A676); // Success
  static const amber   = Color(0xFFFFC107); // Warning
  static const magenta = Color(0xFFD81B60); // Alerts
  static const card    = Color(0xFF12243C); // Navy +10%
}

class ForemanTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ForemanColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: ForemanColors.teal,
      secondary: ForemanColors.green,
      surface: ForemanColors.card,
      onSurface: ForemanColors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: ForemanColors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: ForemanColors.white),
      bodyMedium: TextStyle(color: ForemanColors.white),
    ),
    // NOTE: Flutter now expects CardThemeData here (not CardTheme)
    cardTheme: CardThemeData(
      color: ForemanColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ForemanColors.teal,
        foregroundColor: ForemanColors.navy,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
