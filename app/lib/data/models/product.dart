class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final int? oldPrice;
  final int stock;
  final String description;
  final List<String> images;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    required this.stock,
    required this.description,
    required this.images,
  });

  /// Primera imagen, mantenida por compatibilidad con productos antiguos.
  String? get image => images.isEmpty ? null : images.first;

  factory Product.fromJson(Map<String, dynamic> j) {
    final raw = j['images'];
    var images = raw is List
        ? raw.whereType<String>().where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList()
        : <String>[];
    if (images.isEmpty && j['image'] is String && (j['image'] as String).isNotEmpty) {
      images = [j['image'] as String];
    }
    return Product(
      id: j['id'] as int,
      name: j['name'] as String,
      category: j['category'] as String,
      price: j['price'] as int,
      oldPrice: j['oldPrice'] as int?,
      stock: j['stock'] as int,
      description: (j['description'] as String?) ?? '',
      images: images.toSet().toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'price': price,
        'oldPrice': oldPrice,
        'stock': stock,
        'description': description,
        'images': images,
        'image': image,
      };

  int? get discount =>
      oldPrice != null && oldPrice! > price ? ((1 - price / oldPrice!) * 100).round() : null;
}
