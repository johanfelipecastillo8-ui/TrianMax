import 'package:web/web.dart' as web;
import 'package:material_ui/material_ui.dart';
import '../../core/responsive.dart';
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
    final t = web.window.localStorage.getItem('tm_token');
    if (t != null && t.isNotEmpty) Api.token = t;
    setState(() => ready = true);
  }

  void _logout() async {
    await Api.logout();
    web.window.localStorage.removeItem('tm_token');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Scaffold(body: Center(child: CircularProgressIndicator(color: T.gold)));
    if (Api.token == null) return Scaffold(body: SafeArea(child: AdminLogin(onSuccess: () => setState(() {}))));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: T.bg,
          titleSpacing: Responsive.isMobile(context) ? 4 : 16,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: ShaderMask(
              shaderCallback: (r) => T.goldGradient.createShader(r),
              child: Text('TRIAN MAX${Responsive.isMobile(context) ? '' : ' · Panel'}', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: Responsive.isMobile(context) ? 13 : 16)),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: T.goldDark,
            labelColor: T.goldLight,
            unselectedLabelColor: T.muted,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
            labelPadding: EdgeInsets.symmetric(horizontal: 14),
            tabs: [Tab(text: 'Productos'), Tab(text: 'Pedidos'), Tab(text: 'Ajustes')],
          ),
          actions: [
            IconButton(
              tooltip: 'Ver catálogo',
              onPressed: () => Navigator.of(context).pushNamed('/'),
              icon: const Icon(Icons.storefront_outlined, size: 19),
            ),
            IconButton(tooltip: 'Cerrar sesión', onPressed: _logout, icon: const Icon(Icons.logout, size: 19)),
          ],
        ),
        body: const TabBarView(children: [AdminProductsTab(), AdminOrdersTab(), AdminSettingsTab()]),
      ),
    );
  }
}
