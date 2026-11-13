class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final int? oldPrice;
  final int stock;
  final String description;
  final String? image;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    required this.stock,
    required this.description,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as int,
        name: j['name'] as String,
        category: j['category'] as String,
        price: j['price'] as int,
        oldPrice: j['oldPrice'] as int?,
        stock: j['stock'] as int,
        description: (j['description'] as String?) ?? '',
        image: j['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'price': price,
        'oldPrice': oldPrice,
        'stock': stock,
        'description': description,
        if (image != null) 'image': image,
      };

  int? get discount =>
      oldPrice != null && oldPrice! > price ? ((1 - price / oldPrice!) * 100).round() : null;
}
