// lib/theme/app_theme.dart
//
// Central theme for IngredientConservo.
//
// Brand palette (light mode — currently active):
//   darkGreen      #3F5E4A   primary accents, headings
//   mutedOlive     #6E7F5F   secondary accents
//   warmGold       #B59A6A   tertiary / highlight
//   lightBeige     #F4EFEA   page background
//   cardBackground #E9E3DC   card surfaces
//   softGrayText   #7A7A7A   muted text
//   white          #FFFFFF
//
// A dark-mode palette is defined but NOT wired up — it is prepared so we can
// switch themes later without re-auditing color usage. All widgets should read
// from `AppColors` (via `AppColors.current(context)` or direct constants).

import 'package:flutter/material.dart';

class AppColors {
  // Light (active) palette
  static const Color darkGreen = Color(0xFF3F5E4A);
  static const Color mutedOlive = Color(0xFF6E7F5F);
  static const Color warmGold = Color(0xFFB59A6A);
  static const Color lightBeige = Color(0xFFF4EFEA);
  static const Color cardBackground = Color(0xFFE9E3DC);
  static const Color softGrayText = Color(0xFF7A7A7A);
  static const Color white = Color(0xFFFFFFFF);

  // Functional semantic colors (kept for expiry / status indicators)
  static const Color danger = Color(0xFFC05050);
  static const Color warn = Color(0xFFE8A838);
  static const Color good = Color(0xFF6BAF7A);

  // Dark palette — prepared for future use (NOT active).
  static const Color darkBackground = Color(0xFF1F2A23);
  static const Color darkCard = Color(0xFF2A362E);
  static const Color darkTextPrimary = Color(0xFFF4EFEA);
  static const Color darkTextMuted = Color(0xFFA9B4AC);
  static const Color darkGreenAccent = Color(0xFF6E9A7E);
  static const Color darkOliveAccent = Color(0xFF9AA886);
  static const Color darkGoldAccent = Color(0xFFCDB283);
}

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.darkGreen,
      onPrimary: AppColors.white,
      secondary: AppColors.mutedOlive,
      onSecondary: AppColors.white,
      tertiary: AppColors.warmGold,
      onTertiary: AppColors.white,
      surface: AppColors.cardBackground,
      onSurface: Color(0xFF2A2A2A),
      error: AppColors.danger,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBeige,
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBeige,
        foregroundColor: AppColors.darkGreen,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkGreen),
        titleTextStyle: TextStyle(
          color: AppColors.darkGreen,
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.darkGreen),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(color: AppColors.softGrayText),
        labelStyle: const TextStyle(color: AppColors.softGrayText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBackground),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBackground),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.darkGreen,
        unselectedItemColor: AppColors.softGrayText,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBackground,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w900),
        bodyLarge: TextStyle(color: Color(0xFF2A2A2A)),
        bodyMedium: TextStyle(color: Color(0xFF2A2A2A)),
        labelLarge: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w800),
      ),
    );
  }

  /// Prepared but not activated — returned by `dark()` so it can be wired up
  /// later (e.g. via a theme toggle) without another pass across the app.
  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkGreenAccent,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.darkOliveAccent,
      onSecondary: AppColors.darkBackground,
      tertiary: AppColors.darkGoldAccent,
      onTertiary: AppColors.darkBackground,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.danger,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Nunito',
    );
  }
}
