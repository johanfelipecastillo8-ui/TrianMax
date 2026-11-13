import 'package:flutter/material.dart';
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
      initialRoute: '/',
      routes: {
        '/': (_) => const CatalogPage(),
        '/admin': (_) => const AdminPage(),
      },
    );
  }
}
