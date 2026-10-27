import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF08111D);
  static const surface = Color(0xFF111F30);
  static const surfaceLight = Color(0xFF192B40);
  static const border = Color(0xFF263A4C);
  static const accent = Color(0xFF28D9CE);
  static const success = Color(0xFF4BE3A2);
  static const warning = Color(0xFFFFBF75);
  static const primaryText = Color(0xFFF2F8FD);
  static const mutedText = Color(0xFF91A6B8);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark, surface: surface),
    appBarTheme: const AppBarTheme(backgroundColor: background, foregroundColor: primaryText, elevation: 0),
    cardTheme: CardThemeData(color: surface, elevation: 0, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: border))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: accent, foregroundColor: background, minimumSize: const Size(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    snackBarTheme: SnackBarThemeData(backgroundColor: surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), behavior: SnackBarBehavior.floating),
  );
}
