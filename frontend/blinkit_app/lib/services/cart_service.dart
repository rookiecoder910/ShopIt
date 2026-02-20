import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/cart_model.dart';

class CartService {
  static Future<Map<String, dynamic>> getCart(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.cartOrderServiceUrl}/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  static Future<void> addToCart(String token, String productId,
      {int quantity = 1,
      String? name,
      double? price,
      String? imageUrl,
      String? unit}) async {
    final body = {
      'product_id': productId,
      'quantity': quantity,
    };
    if (name != null) body['name'] = name;
    if (price != null) body['price'] = price;
    if (imageUrl != null) body['image_url'] = imageUrl;
    if (unit != null) body['unit'] = unit;

    final response = await http.post(
      Uri.parse('${ApiConfig.cartOrderServiceUrl}/cart/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to cart');
    }
  }

  static Future<void> removeFromCart(String token, String productId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.cartOrderServiceUrl}/cart/remove'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart');
    }
  }

  static Future<Map<String, dynamic>> createOrder(
      String token, String address) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.cartOrderServiceUrl}/order/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'delivery_address': address}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to create order');
    }
  }
}
