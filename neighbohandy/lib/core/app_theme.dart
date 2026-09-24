import 'package:flutter/material.dart';
import 'app_colors.dart';

// Legacy color names retained for screens that still use the original theme API.
const darkBackground = AppColors.bgDark;
const darkCard = AppColors.surfaceDark;
const darkCardBorder = AppColors.outlineDark;
const darkInputFill = AppColors.surfaceDark;
const lightAccent = AppColors.primaryDark;
const textPrimary = AppColors.textDark;
const textMuted = AppColors.textSoftDark;
const coralDestructive = AppColors.danger;
const ink = AppColors.textLight;
const mint = AppColors.primary;
const softCream = AppColors.bgLight;
const coral = AppColors.danger;

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AppColors.bgLight,
        surface: AppColors.surfaceLight,
        surfaceVariant: AppColors.surfaceVariantLight,
        outline: AppColors.outlineLight,
        text: AppColors.textLight,
        textSoft: AppColors.textSoftLight,
        primary: AppColors.primary,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AppColors.bgDark,
        surface: AppColors.surfaceDark,
        surfaceVariant: AppColors.surfaceVariantDark,
        outline: AppColors.outlineDark,
        text: AppColors.textDark,
        textSoft: AppColors.textSoftDark,
        primary: AppColors.primaryDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceVariant,
    required Color outline,
    required Color text,
    required Color textSoft,
    required Color primary,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: brightness == Brightness.light ? Colors.white : const Color(0xFF0F221D),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surfaceVariant,
      outline: outline,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Segoe UI',
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w800),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: text),
        bodyMedium: TextStyle(color: text),
        bodySmall: TextStyle(color: textSoft),
        titleLarge: TextStyle(color: text, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: text, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: outline),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: brightness == Brightness.light ? Colors.white : const Color(0xFF0F221D),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: outline),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      dividerColor: outline,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : outline,
        ),
      ),
    );
  }
}
