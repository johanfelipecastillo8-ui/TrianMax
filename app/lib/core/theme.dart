import 'package:material_ui/material_ui.dart';

class T {
  // Paleta sobria con beige como color principal: arena, taupe, grafito y oliva.
  static const bg = Color(0xFFF5F0E8);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF0E7DA);
  static const ink = Color(0xFF2E2A26);
  static const text = ink;
  static const muted = Color(0xFF6E655A);
  static const onAccent = ink;

  // Beige principal y sus variaciones.
  static const beige = Color(0xFFD8C4A8);
  static const beigeDeep = Color(0xFFA88764);
  static const beigeInk = Color(0xFF6E563D);
  static const taupe = Color(0xFF8A735C);
  static const slate = Color(0xFF5A6470);
  static const olive = Color(0xFF5F7A63);
  static const ochre = Color(0xFFA9784F);

  // Nombres anteriores conservados para no romper el resto de la app.
  static const lavender = Color(0xFFE3D6C4);
  static const lavenderDeep = beigeDeep;
  static const blush = Color(0xFFE6D5C6);
  static const blushDeep = Color(0xFFA07F66);
  static const peach = Color(0xFFEAD8C0);
  static const peachDeep = ochre;
  static const mint = Color(0xFFD8E0D2);
  static const mintDeep = olive;
  static const sky = Color(0xFFDCE0E4);
  static const skyDeep = slate;
  static const butter = Color(0xFFEAD9B8);

  // Lavados suaves para fondos, badges y estados.
  static const lavenderWash = Color(0x33E3D6C4);
  static const blushWash = Color(0x33E6D5C6);
  static const peachWash = Color(0x33EAD8C0);
  static const mintWash = Color(0x33D8E0D2);

  static const gold = beigeDeep;
  static const goldLight = beigeInk;
  static const goldDark = Color(0xFF7A5F43);
  static const green = olive;
  static const danger = Color(0xFFBD6F66);
  static const dangerDeep = Color(0xFF9C4F47);
  static const line = Color(0x403A332B);
  static const softLine = Color(0x262E2A26);

  // Gradiente profundo para logotipos sobre fondos claros.
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blushDeep, lavenderDeep, peachDeep],
  );

  // Gradiente beige suave para botones, badges y fondos.
  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blush, lavender, peach],
  );

  static const mintGradient = LinearGradient(
    colors: [mint, Color(0xFFC7D2C0)],
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.light(
          primary: beigeDeep,
          onPrimary: onAccent,
          secondary: beige,
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
            borderSide: const BorderSide(color: beigeDeep, width: 1.4),
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
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 620),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
      );

  static const serif = TextStyle(fontFamily: 'Georgia', fontFamilyFallback: ['serif']);
}
