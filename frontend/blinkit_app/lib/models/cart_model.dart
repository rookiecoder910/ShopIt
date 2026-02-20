class CartItemModel {
  final String productId;
  int quantity;
  final String name;
  final double price;
  final String imageUrl;
  final String unit;

  CartItemModel({
    required this.productId,
    required this.quantity,
    required this.name,
    required this.price,
    this.imageUrl = '',
    this.unit = '1 pc',
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] ?? '',
      quantity: json['quantity'] ?? 1,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      unit: json['unit'] ?? '1 pc',
    );
  }
}
