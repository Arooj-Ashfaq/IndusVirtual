import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kDark = Color(0xFF1C1917);
const kAmber = Color(0xFFFBBF24);
const kAmber2 = Color(0xFFF59E0B);

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: ColorScheme.fromSeed(seedColor: kAmber2, brightness: b),
    scaffoldBackgroundColor: dark ? const Color(0xFF141210) : const Color(0xFFFDF9F2),
    cardColor: dark ? const Color(0xFF24201C) : Colors.white,
  );
  return base.copyWith(textTheme: GoogleFonts.interTextTheme(base.textTheme));
}

extension Palette on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get band => isDark ? const Color(0xFF1B1815) : const Color(0xFFF5F0E6);
  Color get line => isDark ? const Color(0xFF3A342D) : const Color(0xFFE7E0D3);
  Color get muted => isDark ? const Color(0xFFB8B0A4) : const Color(0xFF57534E);
  Color get ink => isDark ? const Color(0xFFFAF7F2) : kDark;
  Color get card => Theme.of(this).cardColor;
}
