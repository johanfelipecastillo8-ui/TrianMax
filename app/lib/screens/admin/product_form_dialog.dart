import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  late final nameCtrl = TextEditingController(text: widget.product?.name ?? '');
  late final catCtrl = TextEditingController(text: widget.product?.category ?? '');
  late final priceCtrl = TextEditingController(text: widget.product == null ? '' : fmtPlain(widget.product!.price));
  late final oldPriceCtrl = TextEditingController(text: widget.product?.oldPrice == null ? '' : fmtPlain(widget.product!.oldPrice!));
  late final stockCtrl = TextEditingController(text: widget.product == null ? '' : '${widget.product!.stock}');
  late final descCtrl = TextEditingController(text: widget.product?.description ?? '');
  String? existingImage;
  List<int>? pickedBytes;
  String? pickedName;
  bool saving = false;

  static String fmtPlain(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  @override
  void initState() {
    super.initState();
    existingImage = widget.product?.image;
  }

  int? parseNum(String v) => int.tryParse(v.replaceAll(RegExp(r'[^\d]'), ''));

  Future<void> _pickImage() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    final file = input.files?.first;
    if (file == null) return;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    setState(() {
      pickedBytes = (reader.result as List).cast<int>();
      pickedName = file.name;
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
      String? imageUrl = existingImage;
      if (pickedBytes != null) imageUrl = await Api.uploadImage(pickedBytes!, pickedName ?? 'producto.jpg');
      await Api.saveProduct(widget.product, {
        'name': nameCtrl.text.trim(),
        'category': catCtrl.text.trim(),
        'price': price,
        'oldPrice': oldPriceCtrl.text.trim().isEmpty ? null : parseNum(oldPriceCtrl.text),
        'stock': stock,
        'description': descCtrl.text.trim(),
        'image': imageUrl,
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
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 130,
              decoration: BoxDecoration(color: T.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: T.line)),
              clipBehavior: Clip.antiAlias,
              child: pickedBytes != null
                  ? Image.memory(Uint8List.fromList(pickedBytes!), fit: BoxFit.contain)
                  : existingImage != null
                      ? ProductImage(image: existingImage, category: catCtrl.text.isEmpty ? 'General' : catCtrl.text)
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_photo_alternate_outlined, color: T.gold, size: 30),
                          SizedBox(height: 6),
                          Text('Toca para agregar una foto', style: TextStyle(color: T.muted, fontSize: 12)),
                        ]),
            ),
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

  Widget _field(TextEditingController ctrl, String hint, {bool numeric = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: T.text),
      decoration: InputDecoration(hintText: hint),
    );
  }
}
