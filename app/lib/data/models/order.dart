class OrderItem {
  final int id;
  final String name;
  final int price;
  final int qty;
  const OrderItem({required this.id, required this.name, required this.price, required this.qty});

  factory OrderItem.fromJson(Map<String, dynamic> j) =>
      OrderItem(id: j['id'], name: j['name'], price: j['price'], qty: j['qty']);
}

class Order {
  final int id;
  final List<OrderItem> items;
  final int subtotal;
  final int shipping;
  final String shipMethod;
  final int total;
  final String name;
  final String phone;
  final String address;
  final String payment;
  final String note;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.shipMethod,
    required this.total,
    required this.name,
    required this.phone,
    required this.address,
    required this.payment,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        items: (j['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
        subtotal: j['subtotal'],
        shipping: j['shipping'],
        shipMethod: j['shipMethod'],
        total: j['total'],
        name: j['name'],
        phone: j['phone'],
        address: (j['address'] as String?) ?? '',
        payment: j['payment'],
        note: (j['note'] as String?) ?? '',
        status: j['status'],
        createdAt: DateTime.parse(j['createdAt']),
      );
}
