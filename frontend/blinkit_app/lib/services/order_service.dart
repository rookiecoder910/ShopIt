import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class OrderService {
  static Future<List<dynamic>> getOrders(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.cartOrderServiceUrl}/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['orders'] ?? [];
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.deliveryServiceUrl}/order/$orderId/status'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load order status');
    }
  }

  static Future<void> advanceOrderStatus(String orderId, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.cartOrderServiceUrl}/order/$orderId/advance'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }
}
