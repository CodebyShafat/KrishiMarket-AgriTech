import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32); // Trustworthy dark green
  static const Color secondaryGreen = Color(0xFF4CAF50); // Fresh leaf green
  static const Color backgroundLight = Color(
    0xFFF9FBE7,
  ); // Light earthy yellow-green
  static const Color textDark = Color(
    0xFF1B5E20,
  ); // Very dark green for contrast

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ), // Increased default size
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 60), // Large touch target
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }
}
