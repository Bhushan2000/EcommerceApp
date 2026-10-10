import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    },
  );

  static ThemeData lightTheme() {
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      pageTransitionsTheme: _pageTransitionsTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        outline: AppColors.borderLight,
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
      dividerColor: AppColors.borderLight,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.textMutedLight,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primary.withAlpha(25),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: fontFamily,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
            fontFamily: fontFamily,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.white,
        elevation: 0,
        dragHandleColor: Color(0xFFCBD5E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusLg),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      pageTransitionsTheme: _pageTransitionsTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        outline: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      dividerColor: AppColors.borderDark,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark,
        foregroundColor: AppColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.textMutedDark,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primary.withAlpha(45),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
              fontFamily: fontFamily,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
            fontFamily: fontFamily,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.cardDark,
        elevation: 0,
        dragHandleColor: Color(0xFF334155),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusLg),
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}
