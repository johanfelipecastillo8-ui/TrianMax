import 'package:material_ui/material_ui.dart';
import '../core/responsive.dart';
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
  final addressCtrl = TextEditingController();
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
    final address = addressCtrl.text.trim();
    String? err;
    if (widget.cart.isEmpty) {
      err = 'Tu carrito está vacío';
    } else if (name.isEmpty) {
      err = 'Completa tu nombre';
    } else if (phone.length < 9) {
      err = 'Ingresa un número de celular válido';
    } else if (address.isEmpty) {
      err = 'Ingresa tu dirección de residencia';
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
        'address': address,
        'payment': payment,
        'shipMethod': shipMethod,
        'note': noteCtrl.text.trim(),
      });
      nameCtrl.clear(); phoneCtrl.clear(); addressCtrl.clear(); noteCtrl.clear();
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
      width: Responsive.drawerWidth(context),
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
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 50, height: 50, child: ProductImage(image: p.image, category: p.category, iconSize: 22))),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(fmt(p.price), style: const TextStyle(color: T.goldLight, fontWeight: FontWeight.w700, fontSize: 12.5)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: T.muted, padding: EdgeInsets.zero, minimumSize: const Size(0, 20), textStyle: const TextStyle(fontSize: 10.5, decoration: TextDecoration.underline)),
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: T.softLine))),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.52),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(fmt(total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: T.goldLight)),
                ),
              ]),
              if (widget.cart.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 8),
                  child: Text(shipCost == 0 ? 'Recojo sin costo' : 'Incluye ${shipLabels[shipMethod]} (${fmt(shipCost)})', textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.muted, fontSize: 11)),
                )
              else
                const SizedBox(height: 12),
              TextField(controller: nameCtrl, enabled: widget.cart.isNotEmpty, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: 'Tu nombre', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, enabled: widget.cart.isNotEmpty, keyboardType: TextInputType.phone, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: 'Tu número de celular', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
              const SizedBox(height: 8),
              TextField(controller: addressCtrl, enabled: widget.cart.isNotEmpty, keyboardType: TextInputType.streetAddress, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: 'Dirección de residencia', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
              const SizedBox(height: 8),
              Row(children: [
                for (final e in shipCosts.entries)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: e.key == 'recojo' ? 6 : 0, left: e.key == 'nacional' ? 6 : (e.key == 'delivery' ? 3 : 0)),
                      child: _shipBtn(e.key, e.value),
                    ),
                  ),
              ]),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: payment,
                dropdownColor: T.surface2,
                isDense: true,
                style: const TextStyle(color: T.text, fontSize: 13),
                decoration: const InputDecoration(hintText: '¿Cómo vas a pagar?', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: const ['Nequi', 'Efectivo']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: widget.cart.isEmpty ? null : (v) => setState(() => payment = v),
              ),
              const SizedBox(height: 8),
              TextField(controller: noteCtrl, enabled: widget.cart.isNotEmpty, maxLines: 1, style: const TextStyle(color: T.text), decoration: const InputDecoration(hintText: 'Nota (opcional)', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
              const SizedBox(height: 10),
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
                      : const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.chat_bubble_outline, size: 17, color: T.onAccent),
                            SizedBox(width: 8),
                            Text('Enviar pedido por WhatsApp', style: TextStyle(color: T.onAccent, fontWeight: FontWeight.w800, fontSize: 14)),
                          ]),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: widget.onAskInfo,
                style: OutlinedButton.styleFrom(foregroundColor: T.goldLight, side: const BorderSide(color: T.line), padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))),
                child: const Text('Solo pedir información', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              ),
              ]),
            ),
          ),
        ),
      ])),
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Padding(padding: const EdgeInsets.all(4), child: Icon(icon, size: 13, color: T.text)),
    );
  }

  Widget _shipBtn(String key, int cost) {
    final active = shipMethod == key;
    final label = {'recojo': 'Recojo', 'delivery': 'Delivery', 'nacional': 'Nacional'}[key]!;
    return GestureDetector(
      onTap: widget.cart.isEmpty ? null : () => setState(() => shipMethod = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: active ? T.lavenderWash : T.surface,
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
