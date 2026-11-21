import 'package:material_ui/material_ui.dart';

class T {
  // Paleta pastel: fondos crema/lavanda y acentos rosado, durazno y menta.
  static const bg = Color(0xFFFDF8FB);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF5EDFA);
  static const ink = Color(0xFF3B3450);
  static const text = ink;
  static const muted = Color(0xFF7C7490);
  static const onAccent = ink;

  static const lavender = Color(0xFFC9B6F0);
  static const lavenderDeep = Color(0xFF8F76BE);
  static const blush = Color(0xFFF6BFD2);
  static const blushDeep = Color(0xFFB96F91);
  static const peach = Color(0xFFFFD6BC);
  static const peachDeep = Color(0xFFC98A62);
  static const mint = Color(0xFFBFE8D2);
  static const mintDeep = Color(0xFF4F9B78);
  static const sky = Color(0xFFC3DDF5);
  static const skyDeep = Color(0xFF5D8FB8);
  static const butter = Color(0xFFFFE6A8);

  // Nombres anteriores conservados para no romper el resto de la app.
  static const gold = lavender;
  static const goldLight = blushDeep;
  static const goldDark = lavenderDeep;
  static const green = mintDeep;
  static const danger = Color(0xFFE58EA3);
  static const dangerDeep = Color(0xFFC25D78);
  static const line = Color(0x339B82CC);
  static const softLine = Color(0x1F3B3450);

  // Gradiente más profundo para texto (legible sobre fondos claros).
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blushDeep, lavenderDeep, peachDeep],
  );

  // Gradiente suave para botones, badges y fondos.
  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blush, lavender, peach],
  );

  static const mintGradient = LinearGradient(
    colors: [mint, Color(0xFFA8DFC4)],
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.light(
          primary: lavenderDeep,
          onPrimary: onAccent,
          secondary: blush,
          onSecondary: onAccent,
          surface: surface,
          onSurface: text,
          error: danger,
          onError: onAccent,
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
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: lavenderDeep, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: dangerDeep),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: dangerDeep, width: 1.4),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      );

  static const serif = TextStyle(fontFamily: 'Georgia', fontFamilyFallback: ['serif']);
}
