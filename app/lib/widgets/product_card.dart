import 'package:material_ui/material_ui.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/models/product.dart';
import 'product_image_carousel.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onView;
  final VoidCallback onAdd;
  const ProductCard({super.key, required this.product, required this.onView, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final p = product;
    final stockLow = p.stock > 0 && p.stock <= 6;
    final stockColor = p.stock == 0 ? T.danger : (stockLow ? const Color(0xFFF0B25E) : const Color(0xFF8FD6A4));

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [T.surface2, T.surface]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 12,
          child: GestureDetector(
            onTap: onView,
            child: Stack(fit: StackFit.expand, children: [
              Hero(
                tag: 'prod_${p.id}',
                child: ProductImageCarousel(images: p.images, category: p.category, iconSize: 46),
              ),
              if (p.discount != null)
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(gradient: T.goldGradient, borderRadius: BorderRadius.circular(99)),
                    child: Text('% OFERTA −${p.discount}%', style: const TextStyle(color: Color(0xFF151005), fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ),
                ),
            ]),
          ),
        ),
        Expanded(
          flex: 11,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.category.toUpperCase(), style: const TextStyle(color: T.gold, fontSize: 9.5, letterSpacing: 3, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, height: 1.15)),
              const SizedBox(height: 4),
              Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.muted, fontSize: 12, height: 1.35)),
              const SizedBox(height: 7),
              Row(children: [
                Text(fmt(p.price), style: const TextStyle(color: T.goldLight, fontWeight: FontWeight.w800, fontSize: 18)),
                if (p.oldPrice != null) ...[
                  const SizedBox(width: 8),
                  Text(fmt(p.oldPrice!), style: const TextStyle(color: T.muted, fontSize: 11.5, decoration: TextDecoration.lineThrough)),
                ],
              ]),
              const SizedBox(height: 5),
              Row(children: [
                Icon(Icons.inventory_2_outlined, size: 12, color: stockColor),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    p.stock == 0 ? 'Agotado' : stockLow ? '${p.stock} disponibles · ¡Últimas unidades!' : '${p.stock} disponibles',
                    style: TextStyle(color: stockColor, fontSize: 11.5, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: p.stock == 0 ? null : onAdd,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: T.goldLight,
                    side: const BorderSide(color: T.line),
                    backgroundColor: const Color(0x14D4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ Agregar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
