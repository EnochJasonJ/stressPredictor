import 'package:flutter/material.dart';

/// App color palette for Stress Predictor app.
/// Uses a highly sophisticated minimalist luxury palette.
class AppColors {
  AppColors._();

  // Primary colors - Minimalist Electric Indigo / Calm Luxury Ocean
  static const Color primary = Color(0xFF4A55A2); // Deep aesthetic indigo
  static const Color primaryLight = Color(0xFF7895CB); // Soft luxury blue
  static const Color primaryDark = Color(0xFF000000); // Pure deep
  
  // Secondary colors - soothing minimalist sage
  static const Color secondary = Color(0xFF8BA888);
  static const Color secondaryLight = Color(0xFFC0D6BE);
  static const Color secondaryDark = Color(0xFF4A6B48);

  // Background colors - Immaculate White space
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F5F7); // Extremely soft grey

  // Text colors - High contrast editorial
  static const Color textPrimary = Color(0xFF09090B); // Not #000, 09090B is softer luxury black
  static const Color textSecondary = Color(0xFF71717A); // Zinc 500
  static const Color textHint = Color(0xFFA1A1AA); // Zinc 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Stress level colors (refreshed into pastel aesthetic variants instead of harsh traffic lights)
  static const Color stressLow = Color(0xFF86E3CE); // Mint
  static const Color stressMedium = Color(0xFFFFDD94); // Soft Amber
  static const Color stressHigh = Color(0xFFFA897B); // Soft Coral

  // Accent colors
  static const Color accent = Color(0xFFCCABDB); // Soft lavender
  static const Color accentLight = Color(0xFFEBD4F5);

  // Chart colors (for fl_chart)
  static const Color chartBar = Color(0xFF4A55A2);
  static const Color chartBackground = Color(0xFFF4F5F7);

  // Utility colors
  static const Color divider = Color(0xFFF4F4F5); // Barely perceptible stroke
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}