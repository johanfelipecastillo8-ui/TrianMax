import 'package:material_ui/material_ui.dart';

/// Utilidades simples para adaptar el layout a móvil, tablet y escritorio.
class Responsive {
  const Responsive._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) => width(context) < 600;

  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;

  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double pagePadding(BuildContext context) {
    final w = width(context);
    if (w < 360) return 12;
    if (w < 600) return 16;
    if (w < 1024) return 24;
    return 40;
  }

  static int productGridColumns(BuildContext context) {
    final w = width(context);
    if (w < 520) return 2;
    if (w < 760) return 3;
    if (w < 1100) return 4;
    return 5;
  }

  static double heroTitleSize(BuildContext context) {
    final w = width(context);
    if (w < 360) return 34;
    if (w < 600) return 44;
    if (w < 1024) return 54;
    return 64;
  }

  static double sectionTitleSize(BuildContext context) =>
      isMobile(context) ? 18 : 22;

  static double drawerWidth(BuildContext context) {
    final w = width(context);
    if (w < 600) return w * 0.94;
    if (w < 1024) return 420;
    return 460;
  }

  static double sheetMaxWidth(BuildContext context) =>
      isMobile(context) ? double.infinity : 620;

  static double dialogMaxWidth(BuildContext context) =>
      isMobile(context) ? double.infinity : 720;

  static double cardElevation(BuildContext context) => isMobile(context) ? 0 : 1;
}
