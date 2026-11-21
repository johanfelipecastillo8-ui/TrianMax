import 'package:material_ui/material_ui.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/models/product.dart';
import 'product_image_carousel.dart';

class ProductSheet extends StatefulWidget {
  final Product product;
  const ProductSheet({super.key, required this.product});

  @override
  State<ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<ProductSheet> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final stockLow = p.stock > 0 && p.stock <= 6;
    final stockColor = p.stock == 0 ? T.dangerDeep : (stockLow ? T.peachDeep : T.mintDeep);

    return DraggableScrollableSheet(
      initialChildSize: .92,
      minChildSize: .5,
      maxChildSize: .95,
      builder: (c, ctrl) => Container(
        decoration: const BoxDecoration(
          color: T.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          border: Border(top: BorderSide(color: T.line)),
        ),
        child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 12, 20, 30), children: [
          Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0x334A4138), borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 14),
          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 320,
                width: double.infinity,
                child: Hero(
                  tag: 'prod_${p.id}',
                  child: ProductImageCarousel(images: p.images, category: p.category, iconSize: 110),
                ),
              ),
            ),
            Positioned(
              top: 10, right: 10,
              child: CircleAvatar(
                backgroundColor: const Color(0xF2F5F0E8),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: T.text,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          Text(p.category.toUpperCase(), style: const TextStyle(color: T.goldDark, fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(p.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(fmt(p.price), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: T.goldLight)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: stockColor.withValues(alpha: .09),
              border: Border.all(color: stockColor.withValues(alpha: .3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.inventory_2_outlined, size: 17, color: stockColor),
              const SizedBox(width: 10),
              Text(
                p.stock == 0 ? 'Agotado temporalmente' : stockLow ? '${p.stock} unidades disponibles · ¡Últimas unidades!' : '${p.stock} unidades disponibles',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: stockColor),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text(p.description, style: const TextStyle(color: T.muted, fontSize: 14.5, height: 1.7)),
          const SizedBox(height: 26),
          Row(children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: T.line), borderRadius: BorderRadius.circular(99)),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.remove, color: T.text), onPressed: qty > 1 ? () => setState(() => qty--) : null),
                SizedBox(width: 30, child: Center(child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
                IconButton(
                  icon: const Icon(Icons.add, color: T.text),
                  onPressed: qty < p.stock ? () => setState(() => qty++) : null,
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(gradient: p.stock == 0 ? null : T.softGradient, borderRadius: BorderRadius.circular(99), color: p.stock == 0 ? T.surface2 : null),
                child: MaterialButton(
                  onPressed: p.stock == 0 ? null : () => Navigator.of(context).pop(qty),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  child: Text(p.stock == 0 ? 'Agotado' : 'Agregar al carrito', style: TextStyle(color: p.stock == 0 ? T.muted : T.onAccent, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
