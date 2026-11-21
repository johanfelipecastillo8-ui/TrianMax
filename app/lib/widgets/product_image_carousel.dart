import 'package:material_ui/material_ui.dart';
import '../core/theme.dart';
import 'product_image.dart';

/// Muestra las fotos de un producto como un carrusel pequeño con flechas e
/// indicadores. Si no hay fotos, muestra el placeholder de la categoría.
class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final String category;
  final double iconSize;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.category,
    this.iconSize = 72,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round();
      if (page != null && page != _index && page >= 0 && page < widget.images.length) {
        setState(() => _index = page);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProductImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _index = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (images.isEmpty)
          ProductImage(image: null, category: widget.category, iconSize: widget.iconSize)
        else
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (i) {
              if (i != _index) setState(() => _index = i);
            },
            itemBuilder: (_, i) => ProductImage(
              image: images[i],
              category: widget.category,
              iconSize: widget.iconSize,
            ),
          ),
        if (images.length > 1 && _index > 0)
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _arrow(Icons.chevron_left, 'Foto anterior', () => _go(_index - 1)),
            ),
          ),
        if (images.length > 1 && _index < images.length - 1)
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _arrow(Icons.chevron_right, 'Foto siguiente', () => _go(_index + 1)),
            ),
          ),
        if (images.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: IgnorePointer(
              child: Semantics(
                label: 'Foto ${_index + 1} de ${images.length}',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 14 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? T.lavenderDeep : const Color(0x99F6BFD2),
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: const [BoxShadow(color: Color(0x334D4066), blurRadius: 3)],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _arrow(IconData icon, String label, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xE6F5EDFA),
            shape: BoxShape.circle,
            border: Border.all(color: T.line),
          ),
          child: Icon(icon, size: 18, color: T.onAccent),
        ),
      ),
    );
  }
}
