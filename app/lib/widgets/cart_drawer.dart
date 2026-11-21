import 'package:material_ui/material_ui.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';
import 'product_image.dart';

class CartDrawer extends StatefulWidget {
  final List<CartItem> cart;
  final Product? Function(int id) productOf;
  final void Function(int id, int delta) onQty;
  final void Function(int id) onRemove;
  final Future<void> Function(Map<String, dynamic> form) onCheckout;
  final VoidCallback onAskInfo;
  const CartDrawer({
    super.key,
    required this.cart,
    required this.productOf,
    required this.onQty,
    required this.onRemove,
    required this.onCheckout,
    required this.onAskInfo,
  });

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  String? payment;
  String shipMethod = 'recojo';
  bool sending = false;

  static const shipCosts = {'recojo': 0, 'delivery': 10000, 'nacional': 15000};

  int get subtotal => widget.cart.fold(0, (s, i) {
        final p = widget.productOf(i.id);
        return s + (p?.price ?? 0) * i.qty;
      });

  Future<void> _submit() async {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    String? err;
    if (widget.cart.isEmpty) {
      err = 'Tu carrito está vacío';
    } else if (name.isEmpty) {
      err = 'Completa tu nombre';
    } else if (phone.length < 9) {
      err = 'Ingresa un número de celular válido';
    } else if (payment == null) {
      err = 'Selecciona cómo vas a pagar';
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: T.danger));
      return;
    }
    setState(() => sending = true);
    try {
      await widget.onCheckout({
        'name': name,
        'phone': phone,
        'payment': payment,
        'shipMethod': shipMethod,
        'note': noteCtrl.text.trim(),
      });
      nameCtrl.clear(); phoneCtrl.clear(); noteCtrl.clear();
      if (mounted) setState(() { payment = null; shipMethod = 'recojo'; });
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipCost = widget.cart.isEmpty ? 0 : (shipCosts[shipMethod] ?? 0);
    final total = subtotal + shipCost;
    return Drawer(
      backgroundColor: T.bg,
      child: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Tu pedido', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            IconButton(icon: const Icon(Icons.close), color: T.text, onPressed: () => Navigator.of(context).maybePop()),
          ]),
        ),
        const Divider(height: 1, color: T.softLine),
        Expanded(
          child: widget.cart.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shopping_cart_outlined, color: T.muted, size: 52),
                  const SizedBox(height: 14),
                  const Text('Tu carrito está vacío', style: TextStyle(color: T.muted, fontSize: 15)),
                  const SizedBox(height: 14),
                  OutlinedButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Explorar catálogo')),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.cart.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final item = widget.cart[i];
                    final p = widget.productOf(item.id);
                    if (p == null) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: T.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: T.line)),
                      child: Row(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 60, height: 60, child: ProductImage(image: p.image, category: p.category, iconSize: 26))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          const SizedBox(height: 3),
                          Text(fmt(p.price), style: const TextStyle(color: T.goldLight, fontWeight: FontWeight.w700, fontSize: 13)),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: T.muted, padding: EdgeInsets.zero, minimumSize: const Size(0, 22), textStyle: const TextStyle(fontSize: 11, decoration: TextDecoration.underline)),
                            onPressed: () => widget.onRemove(item.id),
                            child: const Text('Quitar'),
                          ),
                        ])),
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: T.line), borderRadius: BorderRadius.circular(99)),
                          child: Row(children: [
                            _miniBtn(Icons.remove, () => widget.onQty(item.id, -1)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
                            _miniBtn(Icons.add, () => widget.onQty(item.id, 1)),
                          ]),
                        ),
                      ]),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.softLine))),
          child: SafeArea(
            top: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(fmt(total), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: T.goldLight)),
              ]),
              if (widget.cart.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 12),
                  child: Text(shipCost == 0 ? 'Incluye recojo en tienda (sin costo)' : 'Incluye ${shipLabels[shipMethod]} (${fmt(shipCost)})', textAlign: TextAlign.right, style: const TextStyle(color: T.muted, fontSize: 11.5)),
                )
              else
                const SizedBox(height: 12),
              TextField(controller: nameCtrl, enabled: widget.cart.isNotEmpty, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: 'Tu nombre')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, enabled: widget.cart.isNotEmpty, keyboardType: TextInputType.phone, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: 'Tu número de celular')),
              const SizedBox(height: 10),
              Row(children: [
                for (final e in shipCosts.entries)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: e.key == 'recojo' ? 6 : 0, left: e.key == 'nacional' ? 6 : (e.key == 'delivery' ? 3 : 0)),
                      child: _shipBtn(e.key, e.value),
                    ),
                  ),
              ]),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: payment,
                dropdownColor: T.surface2,
                style: const TextStyle(color: T.text, fontSize: 14),
                decoration: const InputDecoration(hintText: '¿Cómo vas a pagar?'),
                items: const ['Efectivo', 'Yape', 'Plin', 'Transferencia bancaria', 'Tarjeta']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: widget.cart.isEmpty ? null : (v) => setState(() => payment = v),
              ),
              const SizedBox(height: 10),
              TextField(controller: noteCtrl, enabled: widget.cart.isNotEmpty, maxLines: 2, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: 'Nota (opcional)')),
              const SizedBox(height: 14),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: widget.cart.isEmpty ? null : T.mintGradient,
                  borderRadius: BorderRadius.circular(99),
                  color: widget.cart.isEmpty ? T.surface2 : null,
                ),
                child: MaterialButton(
                  onPressed: widget.cart.isEmpty || sending ? null : _submit,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  child: sending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: T.onAccent))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.chat_bubble_outline, size: 18, color: T.onAccent),
                          SizedBox(width: 9),
                          Text('Enviar pedido por WhatsApp', style: TextStyle(color: T.onAccent, fontWeight: FontWeight.w800, fontSize: 15)),
                        ]),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: widget.onAskInfo,
                style: OutlinedButton.styleFrom(foregroundColor: T.goldLight, side: const BorderSide(color: T.line), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))),
                child: const Text('Solo pedir información', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
      ])),
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 15, color: T.text)),
    );
  }

  Widget _shipBtn(String key, int cost) {
    final active = shipMethod == key;
    final label = {'recojo': 'Recojo', 'delivery': 'Delivery', 'nacional': 'Envío nacional'}[key]!;
    return GestureDetector(
      onTap: widget.cart.isEmpty ? null : () => setState(() => shipMethod = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0x33C9B6F0) : T.surface,
          border: Border.all(color: active ? T.gold : T.line, width: active ? 1.5 : 1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(children: [
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: active ? T.goldLight : T.muted)),
          Text(cost == 0 ? 'Gratis' : '+${fmt(cost)}', style: TextStyle(fontSize: 9.5, color: active ? T.goldLight.withValues(alpha: .8) : T.muted.withValues(alpha: .8))),
        ]),
      ),
    );
  }
}
