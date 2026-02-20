import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  double _total = 0;
  bool _isLoading = false;

  List<CartItemModel> get items => _items;
  double get total => _total;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  int getQuantity(String productId) {
    final item = _items.where((i) => i.productId == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  Future<void> loadCart(String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await CartService.getCart(token);
      _items = (data['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList();
      _total = (data['total'] ?? 0).toDouble();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String token, String productId,
      {int quantity = 1,
      String? name,
      double? price,
      String? imageUrl,
      String? unit}) async {
    await CartService.addToCart(token, productId,
        quantity: quantity,
        name: name,
        price: price,
        imageUrl: imageUrl,
        unit: unit);
    await loadCart(token);
  }

  Future<void> removeFromCart(String token, String productId) async {
    await CartService.removeFromCart(token, productId);
    await loadCart(token);
  }

  Future<Map<String, dynamic>> createOrder(
      String token, String address) async {
    final result = await CartService.createOrder(token, address);
    await loadCart(token);
    return result;
  }
}
