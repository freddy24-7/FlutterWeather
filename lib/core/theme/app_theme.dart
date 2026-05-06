import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const Color backgroundDark = Color(0xFF0A0A1A);
  static const Color surfaceCard = Color(0x1AFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF2D2D4E);
}

abstract final class AppTextScale {
  // Base sizes — callers should multiply by MediaQuery.textScalerOf(context).scale(1)
  // or use the responsive() helper to clamp for small screens.
  static const double temp = 96.0;
  static const double city = 32.0;
  static const double label = 16.0;

  /// Returns a font size clamped so it never exceeds [max] on large displays
  /// and never falls below [min] on tiny screens.
  static double responsive(
    BuildContext context,
    double base, {
    double min = 12.0,
    double max = double.infinity,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    // Scale linearly: treat 390 pt (iPhone 14) as the design reference.
    final scaled = base * (width / 390).clamp(0.7, 1.4);
    return scaled.clamp(min, max);
  }
}

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.backgroundDark,
        primary: AppColors.accentBlue,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
