import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEEDFF);

  // Secondary
  static const Color secondary = Color(0xFF00C896);
  static const Color secondaryDark = Color(0xFF00A87D);
  static const Color secondaryLight = Color(0xFFE0FFF7);

  // Accent
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFFF0EB);

  // Neutrals - Light Mode
  static const Color background = Color(0xFFF8F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F2F8);
  static const Color border = Color(0xFFE8E8F0);

  // Neutrals - Dark Mode
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariantDark = Color(0xFF252540);
  static const Color borderDark = Color(0xFF2E2E50);

  // Text - Light Mode
  static const Color textPrimary = Color(0xFF0D0D1A);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color textTertiary = Color(0xFFAEAEC6);

  // Text - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF5F5FF);
  static const Color textSecondaryDark = Color(0xFFA0A0C0);
  static const Color textTertiaryDark = Color(0xFF6060A0);

  // Semantic
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF3B82F6);

  // Rating
  static const Color star = Color(0xFFFFB800);

  // Social
  static const Color google = Color(0xFFEA4335);
  static const Color facebook = Color(0xFF1877F2);
  static const Color apple = Color(0xFF000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D0D2B), Color(0xFF1A1A4E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient offerGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF9A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF00E8AE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
