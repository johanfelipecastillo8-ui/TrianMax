import 'package:material_ui/material_ui.dart';

class T {
  // Paleta blanca con detalles dorados y tipografía negra.
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF7F7F7);
  static const ink = Color(0xFF000000);
  static const text = ink;
  static const muted = Color(0xFF333333);
  static const onAccent = ink;

  // Dorados para bordes, iconos, badges y acentos.
  static const beige = Color(0xFFF7E9C6);
  static const beigeDeep = Color(0xFFB8860B);
  static const beigeInk = Color(0xFF8A6A12);
  static const taupe = Color(0xFF7A6A4F);
  static const slate = Color(0xFF4A4A4A);
  static const olive = Color(0xFF4F7A4F);
  static const ochre = Color(0xFFB8860B);

  // Nombres anteriores conservados para no romper el resto de la app.
  static const lavender = Color(0xFFF5E7C3);
  static const lavenderDeep = beigeDeep;
  static const blush = Color(0xFFF8EBCF);
  static const blushDeep = Color(0xFFD4AF37);
  static const peach = Color(0xFFF6E7C8);
  static const peachDeep = ochre;
  static const mint = Color(0xFFE9F0E8);
  static const mintDeep = olive;
  static const sky = Color(0xFFECECEC);
  static const skyDeep = slate;
  static const butter = Color(0xFFF7E7B0);

  // Lavados suaves para fondos, badges y estados.
  static const lavenderWash = Color(0x33F5E7C3);
  static const blushWash = Color(0x33F8EBCF);
  static const peachWash = Color(0x33F6E7C8);
  static const mintWash = Color(0x33E9F0E8);

  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFA8801F);
  static const goldDark = Color(0xFF8A6A12);
  static const green = olive;
  static const danger = Color(0xFFC0392B);
  static const dangerDeep = Color(0xFF96281B);
  static const line = Color(0x33333333);
  static const softLine = Color(0x1A000000);

  // Gradiente dorado para detalles decorativos.
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [beigeDeep, gold, goldLight],
  );

  // Gradiente dorado suave para botones, badges y fondos.
  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blush, lavender, peach],
  );

  static const mintGradient = LinearGradient(
    colors: [mint, Color(0xFFDCE8DA)],
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
