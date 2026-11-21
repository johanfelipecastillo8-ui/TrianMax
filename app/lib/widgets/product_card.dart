import 'package:material_ui/material_ui.dart';
import '../core/responsive.dart';
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
    final stockColor = p.stock == 0 ? T.dangerDeep : (stockLow ? T.peachDeep : T.mintDeep);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [T.surface2, T.surface]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: T.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 8,
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
                    decoration: BoxDecoration(gradient: T.softGradient, borderRadius: BorderRadius.circular(99)),
                    child: Text('% OFERTA −${p.discount}%', style: const TextStyle(color: T.onAccent, fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ),
                ),
            ]),
          ),
        ),
        Expanded(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.category.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.goldDark, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.isMobile(context) ? 13.5 : 15.5, height: 1.15)),
              const SizedBox(height: 4),
              Text(p.description, maxLines: Responsive.isMobile(context) ? 1 : 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: T.muted, fontSize: 11.5, height: 1.3)),
              const SizedBox(height: 7),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(fmt(p.price), style: TextStyle(color: T.goldLight, fontWeight: FontWeight.w800, fontSize: Responsive.isMobile(context) ? 15 : 18)),
                  if (p.oldPrice != null) ...[
                    const SizedBox(width: 8),
                    Text(fmt(p.oldPrice!), style: const TextStyle(color: T.muted, fontSize: 11, decoration: TextDecoration.lineThrough)),
                  ],
                ]),
              ),
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
                    backgroundColor: T.lavenderWash,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('+ Agregar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
