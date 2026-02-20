class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItemModel> items;
  final double total;
  final String status;
  final String deliveryAddress;
  final String createdAt;
  final List<StatusHistoryItem>? statusHistory;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    this.deliveryAddress = '',
    required this.createdAt,
    this.statusHistory,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? '',
      userId: json['user_id'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'PLACED',
      deliveryAddress: json['delivery_address'] ?? '',
      createdAt: json['created_at'] ?? '',
      statusHistory: (json['status_history'] as List<dynamic>?)
          ?.map((e) => StatusHistoryItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class StatusHistoryItem {
  final String status;
  final String timestamp;

  StatusHistoryItem({required this.status, required this.timestamp});

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
