import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders(String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await OrderService.getOrders(token);
      _orders = data.map((e) => OrderModel.fromJson(e)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
