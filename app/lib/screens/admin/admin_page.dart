import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/services/api_service.dart';
import 'login_view.dart';
import 'orders_tab.dart';
import 'products_tab.dart';
import 'settings_tab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool ready = false;

  @override
  void initState() {
    super.initState();
    final t = html.window.localStorage['tm_token'];
    if (t != null && t.isNotEmpty) Api.token = t;
    setState(() => ready = true);
  }

  void _logout() async {
    await Api.logout();
    html.window.localStorage.remove('tm_token');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Scaffold(body: Center(child: CircularProgressIndicator(color: T.gold)));
    if (Api.token == null) return Scaffold(body: AdminLogin(onSuccess: () => setState(() {})));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: T.bg,
          title: ShaderMask(
            shaderCallback: (r) => T.goldGradient.createShader(r),
            child: const Text('TRIAN MAX · Panel', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
          ),
          bottom: const TabBar(
            indicatorColor: T.gold,
            labelColor: T.goldLight,
            unselectedLabelColor: T.muted,
            labelStyle: TextStyle(fontWeight: FontWeight.w700),
            tabs: [Tab(text: 'Productos'), Tab(text: 'Pedidos'), Tab(text: 'Ajustes')],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/'),
              icon: const Icon(Icons.storefront_outlined, size: 17),
              label: const Text('Ver catálogo', style: TextStyle(fontSize: 12)),
            ),
            IconButton(tooltip: 'Cerrar sesión', onPressed: _logout, icon: const Icon(Icons.logout, size: 19)),
          ],
        ),
        body: const TabBarView(children: [AdminProductsTab(), AdminOrdersTab(), AdminSettingsTab()]),
      ),
    );
  }
}
