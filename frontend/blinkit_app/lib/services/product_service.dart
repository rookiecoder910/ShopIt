import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product_model.dart';

class ProductService {
  static Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.productServiceUrl}/categories'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<ProductModel>> getProducts({String? category, String? search}) async {
    String url = '${ApiConfig.productServiceUrl}/products';
    List<String> params = [];
    if (category != null) params.add('category=$category');
    if (search != null) params.add('search=$search');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['products'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<ProductModel> getProduct(String productId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.productServiceUrl}/products/$productId'),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }
}
