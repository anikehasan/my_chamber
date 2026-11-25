import 'package:flutter/material.dart';

class AppTheme {
  // Primary Royal Medical Indigo & Electric Violet Palette
  static const Color royalIndigo = Color(0xFF4C51BF);
  static const Color deepIndigo = Color(0xFF2D3180);
  static const Color vibrantViolet = Color(0xFF6C63FF);
  static const Color darkNavBg = Color(0xFF1E1B3A);

  // Soft Surfaces & Pastels
  static const Color iceSurface = Color(0xFFF0F4FC);
  static const Color mintAccent = Color(0xFF10B981);
  static const Color softMint = Color(0xFFD1FAE5);
  static const Color softPink = Color(0xFFFFE4E6);
  static const Color softAmber = Color(0xFFFEF3C7);
  static const Color softLavender = Color(0xFFE0E7FF);

  static const Color textDark = Color(0xFF16192C);
  static const Color textMuted = Color(0xFF6B7280);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalIndigo,
        primary: royalIndigo,
        secondary: vibrantViolet,
        surface: iceSurface,
      ),
      scaffoldBackgroundColor: iceSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: royalIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: royalIndigo, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
