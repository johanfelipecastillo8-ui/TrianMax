import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'core/theme.dart';
import 'screens/admin/admin_page.dart';
import 'screens/catalog/catalog_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  runApp(const TrianMaxApp());
}

class TrianMaxApp extends StatelessWidget {
  const TrianMaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRIAN MAX — Catálogo 2026',
      debugShowCheckedModeBanner: false,
      theme: T.theme,
      builder: (context, child) {
        final scale = MediaQuery.of(context).textScaler.scale(1).clamp(1.0, 1.15);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (_) => const CatalogPage(),
        '/admin': (_) => const AdminPage(),
      },
    );
  }
}
