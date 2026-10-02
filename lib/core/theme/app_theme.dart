import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bengal-themed Light & Dark Theme Definitions
class AppTheme {
  // Brand colors
  static const Color primaryGreen = Color(0xFF025939); // Deep Bengal Emerald
  static const Color primaryLight = Color(0xFF038756);
  static const Color accentNeon = Color(0xFF00FF87);    // Cyber Neon Green
  static const Color darkCanvas = Color(0xFF141315);    // Obsidian Dark Surface
  static const Color darkCard = Color(0xFF201F22);
  static const Color darkBorder = Color(0xFF363436);

  static const Color lightCanvas = Color(0xFFF8FAF9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: accentNeon,
        onPrimary: Color(0xFF00381B),
        secondary: primaryLight,
        surface: darkCard,
        onSurface: Color(0xFFECEFF1),
        outline: darkBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCanvas,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightCanvas,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: primaryLight,
        surface: lightCard,
        onSurface: Color(0xFF1E293B),
        outline: lightBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCanvas,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
    );
  }
}
