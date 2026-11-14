import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/cart_drawer.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_sheet.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<Product> products = [];
  List<CartItem> cart = [];
  String whatsapp = '573223201720';
  String activeCat = 'Todos';
  String query = '';
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await Api.getProducts();
      final wa = await Api.getWhatsApp();
      if (mounted) setState(() { products = data; whatsapp = wa; loading = false; error = null; });
    } catch (e) {
      if (mounted) setState(() { loading = false; error = 'No se pudo conectar con el servidor'; });
    }
  }

  void _loadCart() {
    try {
      final raw = html.window.localStorage['tm_cart'];
      if (raw != null && raw.isNotEmpty) {
        cart = (jsonDecode(raw) as Map<String, dynamic>).entries
            .map((e) => CartItem(id: int.parse(e.key), qty: (e.value as num).toInt()))
            .toList();
      }
    } catch (_) {}
  }

  void _saveCart() {
    html.window.localStorage['tm_cart'] = jsonEncode({for (var i in cart) '${i.id}': i.qty});
  }

  Product? _product(int id) {
    for (final p in products) { if (p.id == id) return p; }
    return null;
  }

  int get cartCount => cart.fold(0, (s, i) => s + i.qty);

  void addToCart(int id, int qty) {
    final p = _product(id);
    if (p == null || p.stock == 0) return;
    final item = cart.where((i) => i.id == id).firstOrNull;
    final current = item?.qty ?? 0;
    if (current + qty > p.stock) {
      _toast('Solo hay ${p.stock} unidades de ${p.name}');
      return;
    }
    setState(() {
      if (item != null) { item.qty += qty; } else { cart.add(CartItem(id: id, qty: qty)); }
    });
    _saveCart();
    _toast('${p.name} agregado al carrito');
  }

  void changeQty(int id, int delta) {
    final item = cart.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    final p = _product(id);
    if (delta > 0 && p != null && item.qty + delta > p.stock) {
      _toast('Solo hay ${p.stock} unidades disponibles');
      return;
    }
    setState(() {
      item.qty += delta;
      if (item.qty <= 0) cart.removeWhere((i) => i.id == id);
    });
    _saveCart();
  }

  void removeItem(int id) {
    setState(() => cart.removeWhere((i) => i.id == id));
    _saveCart();
  }

  void clearCart() {
    setState(() => cart.clear());
    _saveCart();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> openProduct(Product p) async {
    final qty = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductSheet(product: p),
    );
    if (qty != null && qty > 0) addToCart(p.id, qty);
  }

  Future<void> checkout(Map<String, dynamic> form) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final order = await Api.createOrder({
        'name': form['name'],
        'phone': form['phone'],
        'payment': form['payment'],
        'shipMethod': form['shipMethod'],
        'note': form['note'],
        'items': [for (var i in cart) {'id': i.id, 'qty': i.qty}],
      });
      clearCart();
      await _fetch();
      Navigator.of(context).maybePop();
      scaffold.showSnackBar(SnackBar(content: Text('Pedido #${order.id} registrado. Abriendo WhatsApp…')));
      final msg = StringBuffer()
        ..writeln('*PEDIDO #${order.id} — TRIAN MAX*')
        ..writeln('------------------------------');
      for (final it in order.items) {
        msg.writeln('▪ ${it.qty}x ${it.name} — ${fmt(it.price * it.qty)}');
      }
      msg
        ..writeln('------------------------------')
        ..writeln('Subtotal: ${fmt(order.subtotal)}')
        ..writeln('${shipLabels[order.shipMethod]}: ${fmt(order.shipping)}')
        ..writeln('*TOTAL: ${fmt(order.total)}*')
        ..writeln('')
        ..writeln('Nombre: ${order.name}')
        ..writeln('Celular: ${order.phone}')
        ..writeln('Entrega: ${shipLabels[order.shipMethod]}')
        ..writeln('Pago: ${order.payment}');
      if (order.note.isNotEmpty) msg.writeln('Nota: ${order.note}');
      html.window.open('https://wa.me/$whatsapp?text=${Uri.encodeComponent(msg.toString())}', '_blank');
    } on ApiException catch (e) {
      await _fetch();
      scaffold.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: T.danger));
    }
  }

  void askInfo() {
    html.window.open(
      'https://wa.me/$whatsapp?text=${Uri.encodeComponent('Hola TRIAN MAX, quisiera más información sobre los productos del catálogo 2026.')}',
      '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cats = ['Todos', ...products.map((p) => p.category).toSet()];
    final filtered = products.where((p) =>
        (activeCat == 'Todos' || p.category == activeCat) &&
        '${p.name} ${p.category} ${p.description}'.toLowerCase().contains(query)).toList();

    return Scaffold(
      endDrawer: CartDrawer(
        cart: cart,
        productOf: _product,
        onQty: changeQty,
        onRemove: removeItem,
        onCheckout: checkout,
        onAskInfo: askInfo,
      ),
      appBar: AppBar(
        backgroundColor: T.bg.withValues(alpha: .85),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/logo-trianmax.jpg', width: 38, height: 38),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (r) => T.goldGradient.createShader(r),
            child: const Text('TRIAN MAX', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.white, fontSize: 15)),
          ),
        ]),
        actions: [
          Builder(builder: (c) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: MaterialButton(
              minWidth: 0,
              padding: EdgeInsets.zero,
              onPressed: () => Scaffold.of(c).openEndDrawer(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(gradient: T.goldGradient, borderRadius: BorderRadius.circular(99)),
                child: Row(children: [
                  const Icon(Icons.shopping_cart_outlined, size: 17, color: Color(0xFF151005)),
                  const SizedBox(width: 7),
                  const Text('Carrito', style: TextStyle(color: Color(0xFF151005), fontWeight: FontWeight.w800, fontSize: 13)),
                  if (cartCount > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(color: const Color(0xFF151005), borderRadius: BorderRadius.circular(99)),
                      child: Text('$cartCount', style: const TextStyle(color: T.goldLight, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ]),
              ),
            ),
          )),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: T.gold))
          : error != null
              ? _ErrorState(message: error!, onRetry: _fetch)
              : RefreshIndicator(
                  color: T.gold,
                  backgroundColor: T.surface,
                  onRefresh: _fetch,
                  child: CustomScrollView(slivers: [
                    SliverToBoxAdapter(child: _hero()),
                    SliverToBoxAdapter(child: _toolbar(cats)),
                    filtered.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text('No encontramos productos para tu búsqueda.', style: TextStyle(color: T.muted))),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 300,
                                childAspectRatio: .56,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (c, i) => ProductCard(product: filtered[i], onView: () => openProduct(filtered[i]), onAdd: () => addToCart(filtered[i].id, 1)),
                                childCount: filtered.length,
                              ),
                            ),
                          ),
                    const SliverToBoxAdapter(child: AppFooter()),
                  ]),
                ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 36),
      decoration: const BoxDecoration(
        gradient: RadialGradient(center: Alignment(0, -.8), radius: 1.4, colors: [Color(0x22D4AF37), T.bg]),
      ),
      child: Column(children: [
        const Text('CATÁLOGO 2026', style: TextStyle(letterSpacing: 10, fontSize: 12, color: T.muted)),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (r) => T.goldGradient.createShader(r),
          child: Text('TRIAN MAX', style: T.serif.copyWith(fontSize: 56, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        Text('Todo lo que buscas, en un solo lugar', style: T.serif.copyWith(fontStyle: FontStyle.italic, color: T.muted, fontSize: 15)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: T.line), borderRadius: BorderRadius.circular(99), color: const Color(0x10D4AF37)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.link_rounded, size: 13, color: T.goldLight),
            SizedBox(width: 6),
            Text('catalogo.org.pe/trian-max', style: TextStyle(color: T.goldLight, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 22),
        Container(width: 70, height: 2, decoration: BoxDecoration(gradient: T.goldGradient, borderRadius: BorderRadius.circular(2))),
      ]),
    );
  }

  Widget _toolbar(List<String> cats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(children: [
        TextField(
          onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
          style: const TextStyle(color: T.text),
          decoration: const InputDecoration(
            hintText: 'Buscar en el catálogo...',
            prefixIcon: Icon(Icons.search, color: T.muted),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final active = cats[i] == activeCat;
              return GestureDetector(
                onTap: () => setState(() => activeCat = cats[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: active ? T.goldGradient : null,
                    color: active ? null : T.surface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: active ? Colors.transparent : const Color(0x14FFFFFF)),
                  ),
                  alignment: Alignment.center,
                  child: Text(cats[i], style: TextStyle(color: active ? const Color(0xFF151005) : T.muted, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_outlined, color: T.muted, size: 46),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: T.muted)),
      const SizedBox(height: 14),
      OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
    ]));
  }
}
