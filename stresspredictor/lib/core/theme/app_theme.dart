import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    background: AppColors.background,
    surface: AppColors.surface,
    foreground: AppColors.textPrimary,
    secondaryText: AppColors.textSecondary,
    primary: AppColors.primary,
    outline: AppColors.divider,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    background: const Color(0xFF18231F),
    surface: const Color(0xFF222F29),
    foreground: const Color(0xFFF0EBDD),
    secondaryText: const Color(0xFFB6BCAF),
    primary: const Color(0xFFA9B88B),
    outline: const Color(0xFF39473F),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color foreground,
    required Color secondaryText,
    required Color primary,
    required Color outline,
  }) {
    final textTheme = GoogleFonts.dmSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: foreground, displayColor: foreground);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
          primary: primary,
          secondary: AppColors.accent,
          surface: surface,
          error: AppColors.error,
        ).copyWith(
          onPrimary: brightness == Brightness.light
              ? AppColors.textOnPrimary
              : const Color(0xFF18231F),
          onSurface: foreground,
          onSurfaceVariant: secondaryText,
          outline: outline,
          outlineVariant: outline,
          surfaceContainerHighest: brightness == Brightness.light
              ? AppColors.surfaceVariant
              : const Color(0xFF2D3A33),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: secondaryText,
          height: 1.45,
        ),
        labelSmall: GoogleFonts.spaceMono(
          textStyle: textTheme.labelSmall,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: foreground,
          letterSpacing: -0.6,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: secondaryText),
        hintStyle: TextStyle(color: secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: brightness == Brightness.light
              ? AppColors.textOnPrimary
              : const Color(0xFF18231F),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: foreground,
        contentTextStyle: TextStyle(color: background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
