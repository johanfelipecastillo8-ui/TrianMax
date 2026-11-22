import 'package:material_ui/material_ui.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/models/order.dart';
import '../../data/services/api_service.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});
  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  List<Order> orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await Api.getOrders();
      if (mounted) setState(() { orders = data; loading = false; });
    } on ApiException {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _setStatus(Order o, String status) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      await Api.setOrderStatus(o.id, status);
      _load();
    } on ApiException catch (e) {
      if (mounted) {
        scaffold.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: T.danger));
      }
    }
  }

  Color statusColor(String s) => switch (s) {
        'nuevo' => T.goldLight,
        'confirmado' => T.skyDeep,
        'entregado' => T.mintDeep,
        _ => T.muted,
      };

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: T.gold));
    if (orders.isEmpty) return const Center(child: Text('Aún no hay pedidos registrados.', style: TextStyle(color: T.muted)));
    return RefreshIndicator(
      color: T.goldDark,
      backgroundColor: T.surface,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final o = orders[i];
          final sc = statusColor(o.status);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: T.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.gold.withValues(alpha: .35)),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 5)),
                BoxShadow(color: Color(0x12D4AF37), blurRadius: 18),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('#${o.id}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: T.text)),
                const SizedBox(width: 10),
                Flexible(child: Text(fmtDate(o.createdAt), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.muted, fontSize: 11.5))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: sc.withValues(alpha: .13), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: o.status,
                      dropdownColor: T.surface2,
                      style: TextStyle(color: sc, fontWeight: FontWeight.w700, fontSize: 12.5),
                      icon: Icon(Icons.arrow_drop_down, size: 18, color: sc),
                      items: orderStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) { if (v != null) _setStatus(o, v); },
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text('${o.name} · ${o.phone}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              if (o.address.isNotEmpty)
                Text('Dirección: ${o.address}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.muted, fontSize: 11.5)),
              Text('${shipLabels[o.shipMethod]} · Pago: ${o.payment}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.muted, fontSize: 11.5)),
              const Divider(height: 18, color: T.softLine),
              for (final it in o.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(children: [
                    Expanded(child: Text('${it.qty}x ${it.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: T.text))),
                    const SizedBox(width: 8),
                    FittedBox(fit: BoxFit.scaleDown, child: Text(fmt(it.price * it.qty), style: const TextStyle(fontSize: 12, color: T.muted))),
                  ]),
                ),
              if (o.shipping > 0)
                Row(children: [
                  Text(shipLabels[o.shipMethod]!, style: const TextStyle(fontSize: 12, color: T.muted)),
                  const Spacer(),
                  Text(fmt(o.shipping), style: const TextStyle(fontSize: 12, color: T.muted)),
                ]),
              const Divider(height: 18, color: T.softLine),
              Row(children: [
                const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12)),
                const Spacer(),
                FittedBox(fit: BoxFit.scaleDown, child: Text(fmt(o.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: T.text))),
              ]),
              if (o.note.isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 8), child: Text('Nota: ${o.note}', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.muted, fontSize: 12, fontStyle: FontStyle.italic))),
            ]),
          );
        },
      ),
    );
  }
}
