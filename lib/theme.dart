import 'package:flutter/material.dart';

/// 🌿 App Theme for Organic Meal Planner
class AppTheme {
  // MAIN COLORS
  static const Color primary = Color(0xFF4CAF50); // Fresh green
  static const Color secondary = Color(0xFF8BC34A); // Light green
  static const Color accent = Color(0xFF33691E); // Deep leaf green
  static const Color background = Color(0xFFF1F8E9); // Soft pale green
  static const Color card = Color(0xFFE8F5E9); // Card background color
  static const Color textDark = Color(0xFF2E7D32); // Deep forest green text
  static const Color textLight = Colors.white;

  // GRADIENTS
  static const LinearGradient organicGradient = LinearGradient(
    colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFFB2DFDB), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // GLOBAL THEME
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: card,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(color: textDark, fontSize: 14),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
