import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.credPink,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.credPink,
        secondary: AppColors.cyberTeal,
        surface: AppColors.surfaceCard,
        background: AppColors.background,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E3445), width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.credPink,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surfaceCard,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hourMinuteColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? const Color(0xFF2E374D)
                : const Color(0xFF161922)),
        hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? AppColors.cyanAccent
                : Colors.white),
        dayPeriodColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? const Color(0xFF2E374D)
                : const Color(0xFF161922)),
        dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? AppColors.cyanAccent
                : Colors.white70),
        dialHandColor: AppColors.cyanAccent,
        dialBackgroundColor: const Color(0xFF161922),
        dialTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? Colors.black
                : Colors.white),
        entryModeIconColor: AppColors.cyanAccent,
        helpTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        cancelButtonStyle: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white60),
        ),
        confirmButtonStyle: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(AppColors.cyanAccent),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceCard,
        headerBackgroundColor: const Color(0xFF161922),
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.cyanAccent;
          }
          return null;
        }),
        dayForegroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.black;
          }
          return Colors.white;
        }),
        todayBorder: const BorderSide(color: AppColors.cyanAccent),
        todayForegroundColor: MaterialStateProperty.all(AppColors.cyanAccent),
        cancelButtonStyle: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white60),
        ),
        confirmButtonStyle: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(AppColors.cyanAccent),
        ),
      ),
    );
  }
}
