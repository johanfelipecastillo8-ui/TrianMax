import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/product.dart';

const String apiBase = String.fromEnvironment('API_BASE', defaultValue: '');

class ApiException implements Exception {
  final List<String> errors;
  final int status;
  ApiException(this.errors, this.status);
  @override
  String toString() => errors.join('\n');
}

class Api {
  static String? token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Uri _u(String path) => Uri.parse('$apiBase$path');

  /* ---------- Productos ---------- */
  static Future<List<Product>> getProducts() async {
    final r = await http.get(_u('/api/products'));
    if (r.statusCode != 200) throw ApiException(['Error cargando productos'], r.statusCode);
    return (jsonDecode(r.body) as List).map((e) => Product.fromJson(e)).toList();
  }

  static Future<Product> saveProduct(Product? existing, Map<String, dynamic> payload) async {
    final r = existing == null
        ? await http.post(_u('/api/products'), headers: _headers, body: jsonEncode(payload))
        : await http.put(_u('/api/products/${existing.id}'), headers: _headers, body: jsonEncode(payload));
    if (r.statusCode == 200 || r.statusCode == 201) return Product.fromJson(jsonDecode(r.body));
    throw ApiException(_errors(r), r.statusCode);
  }

  static Future<void> deleteProduct(int id) async {
    final r = await http.delete(_u('/api/products/$id'), headers: _headers);
    if (r.statusCode != 200) throw ApiException(_errors(r), r.statusCode);
  }

  /* ---------- Imágenes ---------- */
  static Future<String> uploadImage(List<int> bytes, String filename) async {
    final req = http.MultipartRequest('POST', _u('/api/upload'))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));
    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode == 201) return (jsonDecode(body) as Map)['url'];
    throw ApiException(_errorsStr(body), res.statusCode);
  }

  /* ---------- Pedidos ---------- */
  static Future<List<Order>> getOrders() async {
    final r = await http.get(_u('/api/orders'), headers: _headers);
    if (r.statusCode != 200) throw ApiException(_errors(r), r.statusCode);
    return (jsonDecode(r.body) as List).map((e) => Order.fromJson(e)).toList();
  }

  static Future<void> setOrderStatus(int id, String status) async {
    final r = await http.put(_u('/api/orders/$id/status'),
        headers: _headers, body: jsonEncode({'status': status}));
    if (r.statusCode != 200) throw ApiException(_errors(r), r.statusCode);
  }

  static Future<Order> createOrder(Map<String, dynamic> payload) async {
    final r = await http.post(_u('/api/orders'), headers: _headers, body: jsonEncode(payload));
    if (r.statusCode == 201) return Order.fromJson(jsonDecode(r.body));
    throw ApiException(_errors(r), r.statusCode);
  }

  /* ---------- Ajustes ---------- */
  static Future<String> getWhatsApp() async {
    final r = await http.get(_u('/api/settings'));
    if (r.statusCode != 200) return '573209080898';
    return (jsonDecode(r.body) as Map)['whatsapp'];
  }

  static Future<String> saveWhatsApp(String number) async {
    final r = await http.put(_u('/api/settings'),
        headers: _headers, body: jsonEncode({'whatsapp': number}));
    if (r.statusCode != 200) throw ApiException(_errors(r), r.statusCode);
    return (jsonDecode(r.body) as Map)['whatsapp'];
  }

  /* ---------- Auth ---------- */
  static Future<String> login(String password) async {
    final r = await http.post(_u('/api/login'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'password': password}));
    if (r.statusCode == 200) return (jsonDecode(r.body) as Map)['token'];
    throw ApiException(['Contraseña incorrecta'], r.statusCode);
  }

  static Future<void> logout() async {
    if (token == null) return;
    await http.post(_u('/api/logout'), headers: _headers);
    token = null;
  }

  static List<String> _errors(http.Response r) => _errorsStr(r.body);

  static List<String> _errorsStr(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map && j['errors'] is List) return (j['errors'] as List).cast<String>();
      if (j is Map && j['error'] != null) return [j['error']];
    } catch (_) {}
    return ['Error del servidor'];
  }
}
