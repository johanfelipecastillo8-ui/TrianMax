import 'package:material_ui/material_ui.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../../widgets/product_image.dart';
import 'product_form_dialog.dart';

class AdminProductsTab extends StatefulWidget {
  const AdminProductsTab({super.key});
  @override
  State<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<AdminProductsTab> {
  List<Product> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await Api.getProducts();
      if (mounted) setState(() { products = data; loading = false; });
    } on ApiException {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _edit([Product? product]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormDialog(product: product, categories: products.map((p) => p.category).toSet()),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${p.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(style: FilledButton.styleFrom(foregroundColor: T.onAccent, backgroundColor: T.dangerDeep), onPressed: () => Navigator.pop(c, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Api.deleteProduct(p.id);
      _toast('Producto eliminado');
      _load();
    } on ApiException catch (e) {
      _toast(e.toString());
    }
  }

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        backgroundColor: T.gold,
        icon: const Icon(Icons.add, color: T.onAccent),
        label: const Text('Nuevo producto', style: TextStyle(color: T.onAccent, fontWeight: FontWeight.w800)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: T.gold))
          : products.isEmpty
              ? const Center(child: Text('No hay productos. Crea el primero.', style: TextStyle(color: T.muted)))
              : RefreshIndicator(
                  color: T.goldDark,
                  backgroundColor: T.surface,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = products[i];
                      final stockColor = p.stock == 0 ? T.dangerDeep : (p.stock <= 6 ? T.peachDeep : T.mintDeep);
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: T.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: T.line)),
                        child: Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 62, height: 62, child: ProductImage(image: p.image, category: p.category, iconSize: 26))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text(p.category, style: const TextStyle(color: T.muted, fontSize: 11.5)),
                            const SizedBox(height: 3),
                            Row(children: [
                              Text(fmt(p.price), style: const TextStyle(color: T.goldLight, fontWeight: FontWeight.w800, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stockColor.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Stock: ${p.stock}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: stockColor)),
                              ),
                            ]),
                          ])),
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 19, color: T.goldLight), onPressed: () => _edit(p)),
                          IconButton(icon: const Icon(Icons.delete_outline, size: 19, color: T.dangerDeep), onPressed: () => _delete(p)),
                        ]),
                      );
                    },
                  ),
                ),
    );
  }
}
