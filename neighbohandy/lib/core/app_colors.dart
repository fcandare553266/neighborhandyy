import 'package:flutter/material.dart';

/// Shared color tokens for light & dark mode.
/// Same hues in both modes so status meaning never shifts between themes.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0FA88E); // teal
  static const Color primaryDark = Color(0xFF7FB8A4);
  static const Color secondary = Color(0xFF6C4CE0); // purple (avatars, "apply as freelancer")

  // Status (consistent across client / freelancer / admin)
  static const Color pending = Color(0xFFB96A1E);
  static const Color pendingBgLight = Color(0xFFFBEEDD);
  static const Color pendingBgDark = Color(0xFF3A2E1C);

  static const Color confirmed = Color(0xFF0FA88E);
  static const Color confirmedBgLight = Color(0xFFE1F3EF);
  static const Color confirmedBgDark = Color(0xFF123A34);

  static const Color danger = Color(0xFFE5604A);
  static const Color dangerBgLight = Color(0xFFFBE6E1);
  static const Color dangerBgDark = Color(0xFF3A211C);

  // Light surfaces
  static const Color bgLight = Color(0xFFF4F2EC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0EEE7);
  static const Color outlineLight = Color(0xFFE0DCCF);
  static const Color textLight = Color(0xFF1D1D1B);
  static const Color textSoftLight = Color(0xFF706C63);

  // Dark surfaces
  static const Color bgDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1A1A18);
  static const Color surfaceVariantDark = Color(0xFF232320);
  static const Color outlineDark = Color(0xFF2A2A27);
  static const Color textDark = Color(0xFFF2F1EE);
  static const Color textSoftDark = Color(0xFFA6A39A);
}
