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
    return _ShimmerPlaceholder(category: category, iconSize: iconSize);
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final String category;
  final double? iconSize;
  const _ShimmerPlaceholder({required this.category, this.iconSize});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shift = (_controller.value * 2 - 1) * 0.8;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(shift - 0.6, -0.3),
              end: Alignment(shift + 0.6, 0.3),
              colors: const [T.beige, T.surface, T.beige],
            ),
          ),
          child: Center(
            child: Icon(
              categoryIcon(widget.category),
              size: widget.iconSize ?? 72,
              color: T.goldDark.withValues(alpha: .85),
            ),
          ),
        );
      },
    );
  }
}
