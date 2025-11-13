import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class ThemeConfig {
  static ThemeData lightTheme(Color primaryColor) {
    return _baseTheme(primaryColor, Brightness.light).copyWith(
      scaffoldBackgroundColor: AppColors.lightScaffold,
      cardColor: AppColors.lightCard,
      iconTheme: const IconThemeData(color: AppColors.lightIcon),
      textTheme: _textTheme(Brightness.light),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData darkTheme(Color primaryColor) {
    return _baseTheme(primaryColor, Brightness.dark).copyWith(
      scaffoldBackgroundColor: AppColors.darkScaffold,
      cardColor: AppColors.darkCard,
      iconTheme: const IconThemeData(color: AppColors.darkIcon),
      textTheme: _textTheme(Brightness.dark),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData _baseTheme(Color primary, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      primaryColor: primary,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor:
            isLight ? AppColors.lightScaffold : AppColors.darkScaffold,
        foregroundColor:
            isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        selectedColor: primary.withOpacity(0.15),
        backgroundColor: isLight ? Colors.white : Colors.black26,
        labelStyle: TextStyle(
          color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.light ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final secondaryColor =
        brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
    return TextTheme(
      titleLarge: GoogleFonts.urbanist(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.urbanist(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
    );
  }
}
