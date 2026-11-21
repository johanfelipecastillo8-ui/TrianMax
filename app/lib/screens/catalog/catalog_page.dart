import 'dart:async';
import 'dart:convert';
import 'package:web/web.dart' as web;
import 'package:material_ui/material_ui.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/cart_drawer.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_image.dart';
import '../../widgets/product_sheet.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<Product> products = [];
  List<CartItem> cart = [];
  String whatsapp = '573209080898';
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
      if (mounted) {
        setState(() {
          products = data;
          whatsapp = wa;
          loading = false;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'No se pudo conectar con el servidor';
        });
      }
    }
  }

  void _loadCart() {
    try {
      final raw = web.window.localStorage.getItem('tm_cart');
      if (raw != null && raw.isNotEmpty) {
        cart = (jsonDecode(raw) as Map<String, dynamic>)
            .entries
            .map((e) => CartItem(id: int.parse(e.key), qty: (e.value as num).toInt()))
            .toList();
      }
    } catch (_) {}
  }

  void _saveCart() {
    web.window.localStorage.setItem('tm_cart', jsonEncode({for (var i in cart) '${i.id}': i.qty}));
  }

  Product? _product(int id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
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
      if (item != null) {
        item.qty += qty;
      } else {
        cart.add(CartItem(id: id, qty: qty));
      }
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, maxLines: 2, overflow: TextOverflow.ellipsis)));
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
    final navigator = Navigator.of(context);
    try {
      final order = await Api.createOrder({
        'name': form['name'],
        'phone': form['phone'],
        'payment': form['payment'],
        'shipMethod': form['shipMethod'],
        'note': form['note'],
        'items': [
          for (var i in cart) {'id': i.id, 'qty': i.qty}
        ],
      });
      clearCart();
      await _fetch();
      if (mounted) navigator.maybePop();
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
      final encoded = Uri.encodeComponent(msg.toString());
      web.window.open('https://wa.me/$whatsapp?text=$encoded', '_blank');
    } on ApiException catch (e) {
      await _fetch();
      scaffold.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: T.danger));
    }
  }

  void askInfo() {
    final text = Uri.encodeComponent('Hola TRIAN MAX, quisiera más información sobre los productos del catálogo 2026.');
    web.window.open('https://wa.me/$whatsapp?text=$text', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final cats = ['Todos', ...products.map((p) => p.category).toSet()];
    final featured = products.take(6).toList();
    final filtered = products
        .where((p) =>
            (activeCat == 'Todos' || p.category == activeCat) &&
            '${p.name} ${p.category} ${p.description}'.toLowerCase().contains(query))
        .toList();

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
        titleSpacing: Responsive.isMobile(context) ? 4 : 16,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/logo-trianmax.jpg', width: Responsive.isMobile(context) ? 32 : 38, height: Responsive.isMobile(context) ? 32 : 38),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ShaderMask(
              shaderCallback: (r) => T.goldGradient.createShader(r),
              child: Text('TRIAN MAX', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: Responsive.isMobile(context) ? 1 : 2, color: Colors.white, fontSize: Responsive.isMobile(context) ? 13 : 15)),
            ),
          ),
        ]),
        actions: [
          Builder(
            builder: (c) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: MaterialButton(
                minWidth: 0,
                padding: EdgeInsets.zero,
                onPressed: () => Scaffold.of(c).openEndDrawer(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.isMobile(context) ? 10 : 16, vertical: 8),
                  decoration: BoxDecoration(gradient: T.softGradient, borderRadius: BorderRadius.circular(99)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.shopping_cart_outlined, size: 17, color: T.onAccent),
                    if (!Responsive.isMobile(context)) ...[
                      const SizedBox(width: 7),
                      const Text('Carrito', style: TextStyle(color: T.onAccent, fontWeight: FontWeight.w800, fontSize: 13)),
                    ],
                    if (cartCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(color: T.blushDeep, borderRadius: BorderRadius.circular(99)),
                        child: Text('$cartCount', style: const TextStyle(color: T.onAccent, fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: T.gold))
          : error != null
              ? _ErrorState(message: error!, onRetry: _fetch)
              : RefreshIndicator(
                  color: T.goldDark,
                  backgroundColor: T.surface,
                  onRefresh: _fetch,
                  child: CustomScrollView(slivers: [
                    SliverToBoxAdapter(child: _hero()),
                    if (featured.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _FeaturedCarousel(
                          products: featured,
                          onSelect: (product) => openProduct(product as Product),
                        ),
                      ),
                    SliverToBoxAdapter(child: _toolbar(cats)),
                    filtered.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('No encontramos productos para tu búsqueda.', textAlign: TextAlign.center, style: TextStyle(color: T.muted)))),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: Responsive.isMobile(context) ? 220 : 300,
                                childAspectRatio: Responsive.isMobile(context) ? .55 : .62,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
(c, i) => ProductCard(
product: filtered[i],
onView: () => openProduct(filtered[i]),
onAdd: () => addToCart(filtered[i].id, 1),
),
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
padding: EdgeInsets.fromLTRB(
    Responsive.pagePadding(context),
    Responsive.isMobile(context) ? 28 : 48,
    Responsive.pagePadding(context),
    Responsive.isMobile(context) ? 22 : 28,
  ),
decoration: const BoxDecoration(
gradient: RadialGradient(center: Alignment(0, -.8), radius: 1.4, colors: [T.lavenderWash, T.bg]),
),
child: Column(children: [
Text('CATÁLOGO 2026', style: TextStyle(letterSpacing: Responsive.isMobile(context) ? 5 : 10, fontSize: Responsive.isMobile(context) ? 10.5 : 12, color: T.muted)),
const SizedBox(height: 14),
FittedBox(
fit: BoxFit.scaleDown,
child: ShaderMask(
shaderCallback: (r) => T.goldGradient.createShader(r),
child: Text('TRIAN MAX', style: T.serif.copyWith(fontSize: Responsive.heroTitleSize(context), fontWeight: FontWeight.w700, color: Colors.white)),
),
),
const SizedBox(height: 10),
FittedBox(fit: BoxFit.scaleDown, child: Text('Todo lo que buscas, en un solo lugar', style: T.serif.copyWith(fontStyle: FontStyle.italic, color: T.muted, fontSize: Responsive.isMobile(context) ? 13 : 15))),
const SizedBox(height: 22),
Container(width: 70, height: 2, decoration: BoxDecoration(gradient: T.softGradient, borderRadius: BorderRadius.circular(2))),
]),
);
}
Widget _toolbar(List cats) {
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
gradient: active ? T.softGradient : null,
color: active ? null : T.surface,
borderRadius: BorderRadius.circular(99),
border: Border.all(color: active ? Colors.transparent : T.line),
),
alignment: Alignment.center,
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 180),
child: Text(cats[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? T.onAccent : T.muted, fontWeight: FontWeight.w700, fontSize: 13)),
),
),
);
},
),
),
]),
);
}
}
class _FeaturedCarousel extends StatefulWidget {
final List products;
final ValueChanged onSelect;
const _FeaturedCarousel({required this.products, required this.onSelect});
@override
State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}
class _FeaturedCarouselState extends State<_FeaturedCarousel> {
final PageController _ctrl = PageController();
int _index = 0;
Timer? _timer;
@override
void initState() {
super.initState();
_startAutoPlay();
}
void _startAutoPlay() {
_timer?.cancel();
if (widget.products.length > 1) {
_timer = Timer.periodic(const Duration(seconds: 4), (timer) {
if (!_ctrl.hasClients) return;
final next = (_index + 1) % widget.products.length;
_ctrl.animateToPage(
next,
duration: const Duration(milliseconds: 450),
curve: Curves.easeInOut,
);
});
}
}
@override
void didUpdateWidget(covariant _FeaturedCarousel oldWidget) {
super.didUpdateWidget(oldWidget);
if (oldWidget.products.length != widget.products.length) {
_index = 0;
_startAutoPlay();
}
}
@override
void dispose() {
_timer?.cancel();
_ctrl.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
return Padding(
padding: EdgeInsets.fromLTRB(Responsive.pagePadding(context), 0, Responsive.pagePadding(context), 18),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 820),
child: Column(
children: [
SizedBox(
height: Responsive.isMobile(context) ? 150 : 175,
child: PageView.builder(
controller: _ctrl,
itemCount: widget.products.length,
onPageChanged: (i) => setState(() => _index = i),
itemBuilder: (context, i) {
final p = widget.products[i];
return GestureDetector(
onTap: () => widget.onSelect(p),
child: Container(
margin: const EdgeInsets.symmetric(horizontal: 4),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: T.surface,
borderRadius: BorderRadius.circular(18),
border: Border.all(color: T.line),
gradient: const LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [T.blushWash, T.surface],
),
),
child: Row(
children: [
ClipRRect(
borderRadius: BorderRadius.circular(12),
child: SizedBox(
width: Responsive.isMobile(context) ? 88 : 140,
height: double.infinity,
child: ProductImage(image: p.image, category: p.category),
),
),
SizedBox(width: Responsive.isMobile(context) ? 10 : 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(
color: T.lavenderWash,
borderRadius: BorderRadius.circular(99),
border: Border.all(color: T.line),
),
child: Text(
'DESTACADO · ${p.category.toUpperCase()}',
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: TextStyle(color: T.goldLight, fontSize: Responsive.isMobile(context) ? 9 : 10, fontWeight: FontWeight.w700, letterSpacing: Responsive.isMobile(context) ? 0 : 1),
),
),
const SizedBox(height: 10),
Text(
p.name,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: TextStyle(color: T.text, fontSize: Responsive.isMobile(context) ? 14.5 : 17, fontWeight: FontWeight.w800),
),
const SizedBox(height: 8),
FittedBox(
fit: BoxFit.scaleDown,
alignment: Alignment.centerLeft,
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
fmt(p.price),
style: TextStyle(color: T.goldLight, fontSize: Responsive.isMobile(context) ? 15 : 18, fontWeight: FontWeight.w800),
),
if (p.oldPrice != null && p.oldPrice! > p.price) ...[
const SizedBox(width: 8),
Text(
fmt(p.oldPrice!),
style: const TextStyle(
color: T.muted,
fontSize: 12,
decoration: TextDecoration.lineThrough,
),
),
],
],
),
),
],
),
),
if (!Responsive.isMobile(context)) const Icon(Icons.chevron_right_rounded, color: T.goldLight, size: 26),
],
),
),
);
},
),
),
if (widget.products.length > 1) ...[
const SizedBox(height: 10),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: List.generate(widget.products.length, (i) {
final active = i == _index;
return AnimatedContainer(
duration: const Duration(milliseconds: 220),
margin: const EdgeInsets.symmetric(horizontal: 4),
width: active ? 20 : 7,
height: 7,
decoration: BoxDecoration(
color: active ? T.gold : T.line,
borderRadius: BorderRadius.circular(99),
),
);
}),
),
],
],
),
),
),
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