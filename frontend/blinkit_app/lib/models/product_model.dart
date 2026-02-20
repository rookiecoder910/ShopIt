class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool availability;
  final String unit;
  final double discountPercent;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.availability = true,
    this.unit = '1 pc',
    this.discountPercent = 0,
  });

  double get discountedPrice {
    if (discountPercent > 0) {
      return price * (1 - discountPercent / 100);
    }
    return price;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      availability: json['availability'] ?? true,
      unit: json['unit'] ?? '1 pc',
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'availability': availability,
      'unit': unit,
      'discount_percent': discountPercent,
    };
  }
}

class CategoryModel {
  final String categoryId;
  final String name;
  final String imageUrl;
  final String description;

  CategoryModel({
    required this.categoryId,
    required this.name,
    required this.imageUrl,
    this.description = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
