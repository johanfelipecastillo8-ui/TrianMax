import 'dart:js_interop';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:web/web.dart' as web;
import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../../widgets/product_image.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Set<String> categories;
  const ProductFormDialog({super.key, this.product, required this.categories});
  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  static const maxImages = 8;

  late final nameCtrl = TextEditingController(text: widget.product?.name ?? '');
  late final catCtrl = TextEditingController(text: widget.product?.category ?? '');
  late final priceCtrl = TextEditingController(text: widget.product == null ? '' : fmtPlain(widget.product!.price));
  late final oldPriceCtrl = TextEditingController(text: widget.product?.oldPrice == null ? '' : fmtPlain(widget.product!.oldPrice!));
  late final stockCtrl = TextEditingController(text: widget.product == null ? '' : '${widget.product!.stock}');
  late final descCtrl = TextEditingController(text: widget.product?.description ?? '');

  final List<String> keptImages = [];
  final List<Uint8List> newBytes = [];
  final List<String> newNames = [];
  bool saving = false;

  static String fmtPlain(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  void initState() {
    super.initState();
    keptImages.addAll(widget.product?.images ?? []);
  }

  int? parseNum(String v) => int.tryParse(v.replaceAll(RegExp(r'[^\d]'), ''));

  int get imageCount => keptImages.length + newBytes.length;

  static bool _isImageName(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg');
  }

  Future<void> _pickImages() async {
    final scaffold = ScaffoldMessenger.of(context);
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..multiple = true
      ..accept = '.png,.jpg,.jpeg,image/png,image/jpeg';
    input.click();
    await input.onChange.first;

    final files = input.files;
    if (files == null) return;
    final bytesList = <Uint8List>[];
    final namesList = <String>[];
    var invalid = 0;
    for (var i = 0; i < files.length; i++) {
      final file = files.item(i);
      if (file == null) continue;
      if (!_isImageName(file.name)) {
        invalid++;
        continue;
      }
      final buffer = await file.arrayBuffer().toDart;
      bytesList.add(buffer.toDart.asUint8List());
      namesList.add(file.name);
    }

    final room = maxImages - imageCount;
    final accepted = bytesList.length < room ? bytesList.length : room;
    if (mounted) {
      setState(() {
        for (var i = 0; i < accepted; i++) {
          newBytes.add(bytesList[i]);
          newNames.add(namesList[i]);
        }
      });
    }
    if (invalid > 0) {
      scaffold.showSnackBar(const SnackBar(content: Text('Solo se permiten imágenes PNG o JPG'), backgroundColor: T.danger));
    } else if (bytesList.length > room) {
      scaffold.showSnackBar(const SnackBar(content: Text('Máximo $maxImages imágenes por producto'), backgroundColor: T.danger));
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < keptImages.length) {
        keptImages.removeAt(index);
      } else {
        final i = index - keptImages.length;
        newBytes.removeAt(i);
        newNames.removeAt(i);
      }
    });
  }

  Future<void> _save() async {
    final price = parseNum(priceCtrl.text);
    final stock = int.tryParse(stockCtrl.text.trim());
    String? err;
    if (nameCtrl.text.trim().isEmpty) {
      err = 'El nombre es obligatorio';
    } else if (catCtrl.text.trim().isEmpty) {
      err = 'La categoría es obligatoria';
    } else if (price == null || price < 0) {
      err = 'Precio inválido';
    } else if (stock == null || stock < 0) {
      err = 'Stock inválido';
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: T.danger));
      return;
    }
    setState(() => saving = true);
    try {
      final uploaded = <String>[];
      for (var i = 0; i < newBytes.length; i++) {
        uploaded.add(await Api.uploadImage(newBytes[i], newNames[i]));
      }
      final images = [...keptImages, ...uploaded];
      await Api.saveProduct(widget.product, {
        'name': nameCtrl.text.trim(),
        'category': catCtrl.text.trim(),
        'price': price,
        'oldPrice': oldPriceCtrl.text.trim().isEmpty ? null : parseNum(oldPriceCtrl.text),
        'stock': stock,
        'description': descCtrl.text.trim(),
        'images': images,
        'image': images.isEmpty ? null : images.first,
      });
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: T.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(22), children: [
          Text(widget.product == null ? 'Nuevo producto' : 'Editar producto', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Hasta 8 fotos por producto. Se muestran en el orden en que las agregas.', style: TextStyle(color: T.muted, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < imageCount; i++) _imageTile(i),
              if (imageCount < maxImages)
                GestureDetector(
                  onTap: saving ? null : _pickImages,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(color: T.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: T.line)),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_photo_alternate_outlined, color: T.gold, size: 24),
                      SizedBox(height: 5),
                      Text('Agregar', style: TextStyle(color: T.muted, fontSize: 10.5)),
                    ]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _field(nameCtrl, 'Nombre del producto'),
          const SizedBox(height: 10),
          _field(catCtrl, 'Categoría (ej. Audio & sound, Belleza…)'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _field(priceCtrl, 'Precio', numeric: true)),
            const SizedBox(width: 10),
            Expanded(child: _field(oldPriceCtrl, 'Precio anterior (opcional)', numeric: true)),
          ]),
          const SizedBox(height: 10),
          _field(stockCtrl, 'Stock disponible', numeric: true),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            maxLines: 4,
            style: const TextStyle(color: T.text),
            decoration: const InputDecoration(hintText: 'Descripción'),
          ),
          const SizedBox(height: 20),
          Row(children: [
            TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            const Spacer(),
            SizedBox(
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: T.goldGradient, borderRadius: BorderRadius.circular(99)),
                child: MaterialButton(
                  onPressed: saving ? null : _save,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  child: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF151005)))
                      : const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('Guardar', style: TextStyle(color: Color(0xFF151005), fontWeight: FontWeight.w800))),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _imageTile(int index) {
    final isNew = index >= keptImages.length;
    final Widget image;
    if (isNew) {
      image = Image.memory(newBytes[index - keptImages.length], fit: BoxFit.cover);
    } else {
      image = ProductImage(image: keptImages[index], category: catCtrl.text.isEmpty ? 'General' : catCtrl.text, iconSize: 28);
    }
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(color: T.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: T.line)),
          clipBehavior: Clip.antiAlias,
          child: image,
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: saving ? null : () => _removeImage(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(color: Color(0xCC0A0A0D), shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xCC0A0A0D), borderRadius: BorderRadius.circular(6)),
              child: const Text('Principal', style: TextStyle(color: T.goldLight, fontSize: 8.5, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {bool numeric = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: T.text),
      decoration: InputDecoration(hintText: hint),
    );
  }
}
