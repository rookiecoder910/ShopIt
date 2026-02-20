import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  double _getChildAspectRatio(double width) {
    if (width > 900) return 0.72;
    if (width > 600) return 0.70;
    return 0.68;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    productProvider.loadCategories();
    productProvider.loadProducts();
    if (authProvider.token != null) {
      cartProvider.loadCart(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD600),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ShopIt',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            Text(
              'Delivery in 10 minutes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OrderTrackingScreen()),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => PopupMenuButton(
              icon: const Icon(Icons.person),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  enabled: false,
                  child: Text('Hi, ${auth.name ?? "User"}'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderTrackingScreen()),
                    );
                  },
                  child: const Text('My Orders'),
                ),
                PopupMenuItem(
                  onTap: () => auth.logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    color: const Color(0xFFFFD600),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      Provider.of<ProductProvider>(context, listen: false)
                          .loadProducts(search: value);
                    } else {
                      Provider.of<ProductProvider>(context, listen: false)
                          .loadProducts();
                    }
                  },
                ),
              ),

                  // Categories
                  _buildCategoriesSection(),

                  // Products
                  _buildProductsSection(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: _buildCartBar(),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.categories.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final category = provider.categories[index];
                  final isSelected =
                      provider.selectedCategory == category.name;
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        provider.clearFilter();
                        provider.loadProducts();
                      } else {
                        provider.loadProducts(category: category.name);
                      }
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE8F5E9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0C831F)
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Image.network(
                                category.imageUrl,
                                height: 36,
                                width: 36,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.category,
                                  size: 30,
                                  color: Color(0xFF0C831F),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF0C831F)
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Failed to load products'),
                  TextButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('No products found')),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.selectedCategory ?? 'All Products',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (provider.selectedCategory != null)
                    TextButton(
                      onPressed: () {
                        provider.clearFilter();
                        provider.loadProducts();
                      },
                      child: const Text('View All'),
                    ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                final aspectRatio = _getChildAspectRatio(constraints.maxWidth);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(provider.products[index]);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cartProvider, authProvider, _) {
        final quantity = cartProvider.getQuantity(product.productId);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(productId: product.productId),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Discount badge + Image
                Stack(
                  children: [
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Image.network(
                          product.imageUrl,
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.shopping_bag,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    if (product.discountPercent > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discountPercent.toInt()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.unit,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\u20b9${product.discountedPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (product.discountPercent > 0)
                                  Text(
                                    '\u20b9${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                      decoration:
                                          TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            if (quantity == 0)
                              SizedBox(
                                height: 32,
                                child: ElevatedButton(
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
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    textStyle:
                                        const TextStyle(fontSize: 12),
                                  ),
                                  child: const Text('ADD'),
                                ),
                              )
                            else
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C831F),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
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
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Icon(Icons.remove,
                                            size: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        cartProvider.addToCart(
                                          authProvider.token!,
                                          product.productId,
                                          name: product.name,
                                          price: product.discountedPrice,
                                          imageUrl: product.imageUrl,
                                          unit: product.unit,
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Icon(Icons.add,
                                            size: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
    );
  }

  Widget? _buildCartBar() {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cartProvider, authProvider, _) {
        if (cartProvider.itemCount == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF0C831F),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CartScreen()),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${cartProvider.itemCount} items',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\u20b9${cartProvider.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
