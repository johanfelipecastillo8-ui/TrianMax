import 'package:flutter/material.dart';

class T {
  static const bg = Color(0xFF0A0A0D);
  static const surface = Color(0xFF15151C);
  static const surface2 = Color(0xFF1B1B24);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF5D97B);
  static const goldDark = Color(0xFF8A6D1F);
  static const text = Color(0xFFF2EFE6);
  static const muted = Color(0xFF9B97A6);
  static const green = Color(0xFF25D366);
  static const danger = Color(0xFFE5534B);
  static const line = Color(0x24D4AF37);

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7E08A), Color(0xFFD4AF37), Color(0xFF9A7A20)],
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          surface: surface,
          error: danger,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: surface2,
          contentTextStyle: TextStyle(color: text, fontWeight: FontWeight.w600),
          behavior: SnackBarBehavior.floating,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          hintStyle: const TextStyle(color: muted),
          labelStyle: const TextStyle(color: muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0x14FFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: gold, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: danger, width: 1.4),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      );

  static const serif = TextStyle(fontFamily: 'Georgia', fontFamilyFallback: ['serif']);
}
