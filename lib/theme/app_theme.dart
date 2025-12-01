import 'package:flutter/material.dart';

class AppColors {
  // Primary brand (close to teal used on login button)
  static const Color primary = Color(0xFF0D9488); // teal-600
  static const Color primaryDark = Color(0xFF0F766E); // teal-700

  // Background gradient (same as login to keep consistency)
  static const Color backgroundStart = Color(0xFF0A1428);
  static const Color backgroundEnd = Color(0xFF0f2342);

  // Accent / neutral
  static const Color accent = Color(0xFF64748B); // slate

  // Text colors for contrast
  static const Color textPrimary = Colors.white; // primary text on dark bg
  static const Color textSecondary =
      Color(0xFFB0BEC5); // secondary text (lighter gray)
  static const Color textHint = Color(0xFF78909C); // hint/disabled text

  // Success / error
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFE6F9EE);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFDECEC);

  // Card overlay (not const because of withOpacity usage) — provide as getters
  static Gradient get cardGradient => LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.05)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient get backgroundGradient => const LinearGradient(
        colors: [backgroundStart, backgroundEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static Gradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
