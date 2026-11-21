import 'package:material_ui/material_ui.dart';

class T {
  // Paleta pastel elegante: crema cálido, lavanda suave, rosa empolvado y menta salvia.
  static const bg = Color(0xFFFBF8F4);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF4EDE8);
  static const ink = Color(0xFF2E2A38);
  static const text = ink;
  static const muted = Color(0xFF6F6A78);
  static const onAccent = ink;

  static const lavender = Color(0xFFD9CDEA);
  static const lavenderDeep = Color(0xFF6F5B96);
  static const plum = Color(0xFF5C4A80);
  static const blush = Color(0xFFF3D6DE);
  static const blushDeep = Color(0xFFA66B80);
  static const peach = Color(0xFFF6DECB);
  static const peachDeep = Color(0xFFB87A56);
  static const mint = Color(0xFFD6EADB);
  static const mintDeep = Color(0xFF4F8068);
  static const sky = Color(0xFFD7E6F0);
  static const skyDeep = Color(0xFF5C7F9E);
  static const butter = Color(0xFFF4E4BC);

  // Lavados suaves para fondos, badges y estados.
  static const lavenderWash = Color(0x33D9CDEA);
  static const blushWash = Color(0x33F3D6DE);
  static const peachWash = Color(0x33F6DECB);
  static const mintWash = Color(0x33D6EADB);

  // Nombres anteriores conservados para no romper el resto de la app.
  static const gold = lavenderDeep;
  static const goldLight = lavenderDeep;
  static const goldDark = plum;
  static const green = mintDeep;
  static const danger = Color(0xFFD98A98);
  static const dangerDeep = Color(0xFFB85C70);
  static const line = Color(0x406F5B96);
  static const softLine = Color(0x2E2E2A38);

  // Gradiente profundo para logotipos sobre fondos claros.
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
    colors: [mint, Color(0xFFC3DFCB)],
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
