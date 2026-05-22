// lib/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Palet warna Origami (Tobiichi Origami vibes) ──────────────────────────
class AppColors {
  // Blues
  static const Color deepBlue    = Color(0xFF0D2B6B); // biru tua gelap
  static const Color midBlue     = Color(0xFF1A4FA0); // biru medium
  static const Color lightBlue   = Color(0xFF4A90D9); // biru muda cerah
  static const Color paleBlue    = Color(0xFFB8D4F5); // biru pucat
  static const Color iceBlue     = Color(0xFFE8F2FC); // biru es hampir putih

  // Whites
  static const Color pureWhite   = Color(0xFFFFFFFF);
  static const Color softWhite   = Color(0xFFF4F8FE);

  // Accents
  static const Color accentGlow  = Color(0xFF64B5F6);
  static const Color shimmerBase = Color(0xFFCDE3FA);

  // Status
  static const Color watching    = Color(0xFF1A4FA0);
  static const Color completed   = Color(0xFF0D7A4E);
  static const Color watchlist   = Color(0xFF8B6914);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.softWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.midBlue,
        secondary: AppColors.lightBlue,
        surface: AppColors.pureWhite,
        onPrimary: AppColors.pureWhite,
        onSecondary: AppColors.pureWhite,
        onSurface: AppColors.deepBlue,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.raleway(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.deepBlue,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.raleway(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.deepBlue,
        ),
        titleLarge: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.deepBlue,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.deepBlue,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.deepBlue,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 13,
          color: AppColors.midBlue,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.lightBlue,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.deepBlue,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.raleway(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.deepBlue,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.iceBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBlue, width: 2),
        ),
        hintStyle: GoogleFonts.nunito(color: AppColors.paleBlue),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
