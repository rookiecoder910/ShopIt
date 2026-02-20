import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await ProductService.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({String? category, String? search}) async {
    try {
      _isLoading = true;
      _error = null;
      _selectedCategory = category;
      notifyListeners();

      _products = await ProductService.getProducts(
        category: category,
        search: search,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilter() {
    _selectedCategory = null;
    notifyListeners();
  }
}
