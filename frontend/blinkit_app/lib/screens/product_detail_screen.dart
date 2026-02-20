import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await ProductService.getProduct(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final product = _product!;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFFFFD600),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Product Image
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[100],
              child: Center(
                child: Image.network(
                  product.imageUrl,
                  height: 150,
                  width: 150,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.shopping_bag,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Row(
                    children: [
                      Text(
                        '\u20b9${product.discountedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C831F),
                        ),
                      ),
                      if (product.discountPercent > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\u20b9${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discountPercent.toInt()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Availability
                  Row(
                    children: [
                      Icon(
                        product.availability
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: product.availability
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.availability ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: product.availability
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Delivery info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD600)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.flash_on, color: Color(0xFFFFD600)),
                        SizedBox(width: 8),
                        Text(
                          'Delivery in 10 minutes',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
      bottomNavigationBar: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, _) {
          final quantity = cartProvider.getQuantity(product.productId);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: quantity == 0
                  ? ElevatedButton(
                      onPressed: product.availability
                          ? () {
                              cartProvider.addToCart(
                                authProvider.token!,
                                product.productId,
                                name: product.name,
                                price: product.discountedPrice,
                                imageUrl: product.imageUrl,
                                unit: product.unit,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C831F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cartProvider.addToCart(
                                      authProvider.token!,
                                      product.productId,
                                      quantity: -1,
                                      name: product.name,
                                      price: product.discountedPrice,
                                      imageUrl: product.imageUrl,
                                      unit: product.unit,
                                    );
                                  },
                                  icon: const Icon(Icons.remove,
                                      color: Colors.white),
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    cartProvider.addToCart(
                                      authProvider.token!,
                                      product.productId,
                                      name: product.name,
                                      price: product.discountedPrice,
                                      imageUrl: product.imageUrl,
                                      unit: product.unit,
                                    );
                                  },
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
