import 'package:flutter/material.dart';

/// App-wide light theme for Inter AI Study Buddy.
ThemeData buildAppTheme() => _base(Brightness.light);

/// App-wide dark theme (great for low-vision students & night study).
ThemeData buildAppDarkTheme() => _base(Brightness.dark);

ThemeData _base(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF006D6F), // deep teal
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: CardThemeData(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    chipTheme: const ChipThemeData(padding: EdgeInsets.symmetric(horizontal: 8)),
  );
}
