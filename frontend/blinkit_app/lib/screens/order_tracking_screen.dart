import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<OrderProvider>(context, listen: false)
          .loadOrders(auth.token!);
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  int _statusIndex(String status) {
    const statuses = ['PLACED', 'PACKED', 'OUT_FOR_DELIVERY', 'DELIVERED'];
    return statuses.indexOf(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFFFFD600),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Consumer2<OrderProvider, AuthProvider>(
            builder: (context, orderProvider, authProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.loadOrders(authProvider.token!),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return _buildOrderCard(order, authProvider.token!);
              },
            ),
          );
        },
      ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, String token) {
    final currentStatusIdx = _statusIndex(order.status);
    final statuses = ['PLACED', 'PACKED', 'OUT_FOR_DELIVERY', 'DELIVERED'];
    final statusLabels = ['Placed', 'Packed', 'Out for\nDelivery', 'Delivered'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderId.substring(order.orderId.length > 8 ? order.orderId.length - 8 : 0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status == 'DELIVERED'
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: order.status == 'DELIVERED'
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(order.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const Divider(height: 24),

            // Progress tracker
            Row(
              children: List.generate(statuses.length, (i) {
                final isCompleted = i <= currentStatusIdx;
                final isLast = i == statuses.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFF0C831F)
                                    : Colors.grey[300],
                              ),
                              child: Icon(
                                isCompleted ? Icons.check : Icons.circle,
                                size: 14,
                                color: isCompleted
                                    ? Colors.white
                                    : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusLabels[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCompleted
                                    ? const Color(0xFF0C831F)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i < currentStatusIdx
                                ? const Color(0xFF0C831F)
                                : Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Items
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child:
                              Text('${item.name} x${item.quantity}')),
                      Text(
                          '\u20b9${(item.price * item.quantity).toStringAsFixed(0)}'),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '\u20b9${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Delivery address
            if (order.deliveryAddress.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],

            // Simulate Next Status button
            if (order.status != 'DELIVERED') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await OrderService.advanceOrderStatus(order.orderId);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      await Provider.of<OrderProvider>(context, listen: false)
                          .loadOrders(auth.token!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order status advanced!'),
                            backgroundColor: Color(0xFF0C831F),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.fast_forward, color: Color(0xFF0C831F)),
                  label: const Text(
                    'Simulate Next Status',
                    style: TextStyle(
                      color: Color(0xFF0C831F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0C831F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }
}
