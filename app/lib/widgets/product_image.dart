import 'package:material_ui/material_ui.dart';
import '../core/theme.dart';

IconData categoryIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('audio')) return Icons.headset_mic_outlined;
  if (c.contains('belleza')) return Icons.spa_outlined;
  if (c.contains('smart')) return Icons.watch_outlined;
  if (c.contains('hogar')) return Icons.chair_outlined;
  return Icons.shopping_bag_outlined;
}

class ProductImage extends StatelessWidget {
  final String? image;
  final String category;
  final double? iconSize;
  const ProductImage({super.key, this.image, required this.category, this.iconSize});

  @override
  Widget build(BuildContext context) {
    if (image != null && image!.isNotEmpty) {
      return Image.network(
        image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (c, w, p) => p == null
            ? w
            : Container(color: T.surface, child: const Center(child: CircularProgressIndicator(color: T.goldDark, strokeWidth: 2))),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.1,
          colors: [T.beige, T.bg],
        ),
      ),
      child: Center(
        child: Icon(categoryIcon(category), size: iconSize ?? 72, color: T.goldDark.withValues(alpha: .85)),
      ),
    );
  }
}
