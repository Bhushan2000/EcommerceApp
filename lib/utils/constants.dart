import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Aura Market';
  static const String appTagline = 'Curated Luxury & Everyday Essentials';

  // Sample Promo Codes for checkout
  static const Map<String, double> promoCodes = {
    'WELCOME10': 0.10, // 10% discount
    'SAVE20': 0.20,    // 20% discount
    'AURA50': 0.50,    // 50% discount
  };

  // Tax rate (8%)
  static const double taxRate = 0.08;
  // Flat standard shipping fee
  static const double standardShippingFee = 15.00;
  // Free shipping threshold
  static const double freeShippingThreshold = 100.00;

  // Placeholder image
  static const String placeholderProductImage =
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80';
}

class AppColors {
  // Brand Primary: Modern Electric Indigo & Royal Violet
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF3730A3);

  // Secondary Accent: Electric Rose & Vibrant Coral
  static const Color secondary = Color(0xFFF43F5E);
  static const Color secondaryLight = Color(0xFFFB7185);
  static const Color secondaryDark = Color(0xFFE11D48);

  // Warm Amber & Gold for Ratings & Featured badges
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);

  // Neutral Tones - Light Mode
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Neutral Tones - Dark Mode (Rich Obsidian Palette)
  static const Color surfaceDark = Color(0xFF090D16);
  static const Color cardDark = Color(0xFF131A2A);
  static const Color cardDarkElevated = Color(0xFF1E273A);
  static const Color borderDark = Color(0xFF243046);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Adaptive Theme Helpers
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;

  static Color cardElevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDarkElevated : Colors.white;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMutedLight;

  // Semantic Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFB7185), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E273A), Color(0xFF131A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppGradients {
  static const LinearGradient primaryGradient = AppColors.primaryGradient;
  static const LinearGradient secondaryGradient = AppColors.secondaryGradient;
  static const LinearGradient darkCardGradient = AppColors.darkCardGradient;
}

class AppStyles {
  // Border Radii
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 22.0;
  static const double radiusXl = 30.0;

  // Reusable Shadow sets
  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withAlpha(80) : const Color(0x0C0F172A),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: isDark ? Colors.black.withAlpha(40) : const Color(0x060F172A),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withAlpha(70),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];
}
