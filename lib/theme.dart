import 'package:flutter/material.dart';

/// 🌿 App Theme for Organic Meal Planner
class AppTheme {
  // MAIN COLORS
  static const Color primary = Color(0xFF4CAF50); // Fresh green
  static const Color secondary = Color(0xFF8BC34A); // Light green
  static const Color accent = Color(0xFF33691E); // Deep leaf green
  static const Color background = Color(0xFFF5F5F5); // Clean light background
  static const Color card = Color(0xFFFFFFFF); // Pure white cards
  static const Color textDark = Color(0xFF1B5E20); // Rich forest green
  static const Color textLight = Colors.white;

  // BOLD VIBRANT GRADIENTS
  static const LinearGradient organicGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF43A047), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient boldGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00C853), Color(0xFF00A344)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFFF8F00), Color(0xFFFFA726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0288D1), Color(0xFF0277BD), Color(0xFF01579B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7E57C2), Color(0xFF5E35B1), Color(0xFF4527A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // TEXT STYLES
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
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
