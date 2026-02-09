import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/summary_card.dart';
import 'pos_controller.dart';
import '../inventory/inventory_controller.dart';
import '../inventory/product_model.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PosController>(context, listen: false).loadRecentSales();
      Provider.of<InventoryController>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
    });
    _quantityController.text = '1';
  }

  void _addToCart() {
    if (_selectedProduct == null) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    if (quantity <= 0) return;

    Provider.of<PosController>(
      context,
      listen: false,
    ).addToCart(_selectedProduct!, quantity);

    setState(() {
      _selectedProduct = null;
      _quantityController.text = '1';
    });
  }

  Future<void> _checkout() async {
    final posController = Provider.of<PosController>(context, listen: false);
    final success = await posController.checkout();

    if (success && mounted) {
      await Provider.of<InventoryController>(context, listen: false)
          .loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.saleCompleted),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(posController.errorMessage ?? 'Checkout failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.posTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Consumer<PosController>(
            builder: (context, posController, child) {
              if (posController.errorMessage == null) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                color: AppColors.error.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Text(
                  posController.errorMessage ?? '',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            },
          ),
          // Search and Product Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: Column(
              children: [
                AppInput(
                  label: 'Search Products',
                  hint: 'Search by name, barcode, or category',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                  onChanged: _filterProducts,
                ),
                const SizedBox(height: 16),

                // Product List
                SizedBox(
                  height: 200,
                  child: Consumer<InventoryController>(
                    builder: (context, inventoryController, child) {
                      if (inventoryController.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<Product> products = inventoryController.products;
                      if (_searchQuery.isNotEmpty) {
                        products = inventoryController.searchProducts(
                          _searchQuery,
                        );
                      }

                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_outlined,
                                size: 48,
                                color: AppColors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No products available'
                                    : 'No products found',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isSelected = _selectedProduct?.id == product.id;

                          return Card(
                            color: isSelected ? AppColors.primaryLight : null,
                            child: ListTile(
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${Helpers.formatCurrency(product.price)} • Stock: ${product.stock}',
                                style: TextStyle(
                                  color: product.isLowStock()
                                      ? AppColors.warning
                                      : product.isOutOfStock()
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                ),
                              ),
                              trailing: Text(
                                product.getStockStatus(),
                                style: TextStyle(
                                  color: product.isLowStock()
                                      ? AppColors.warning
                                      : product.isOutOfStock()
                                      ? AppColors.error
                                      : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => _selectProduct(product),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Selected Product Details
                if (_selectedProduct != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedProduct!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                Helpers.formatCurrency(_selectedProduct!.price),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Available stock: ${_selectedProduct!.stock} units',
                            style: TextStyle(
                              color: _selectedProduct!.isLowStock()
                                  ? AppColors.warning
                                  : _selectedProduct!.isOutOfStock()
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Quantity: '),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              AppButton(
                                text: AppStrings.addToCart,
                                onPressed: _addToCart,
                                isPrimary: false,
                                icon: Icons.add_shopping_cart,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // Cart Section
          Expanded(
            child: Consumer<PosController>(
              builder: (context, posController, child) {
                if (posController.cartItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.cartEmpty,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Cart Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(color: AppColors.primary),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cart Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            '${posController.getCartItemCount()} items',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cart Items List
                    Expanded(
                      child: ListView.builder(
                        itemCount: posController.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = posController.cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${Helpers.formatCurrency(item.price)} each',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${item.stock} ×',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    Helpers.formatCurrency(
                                      item.price * item.stock,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                    ),
                                    onPressed: () {
                                      posController.removeFromCart(item.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Checkout Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                Helpers.formatCurrency(posController.cartTotal),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            text: AppStrings.checkout,
                            onPressed: posController.isLoading
                                ? null
                                : _checkout,
                            isLoading: posController.isLoading,
                            width: double.infinity,
                            icon: Icons.payment,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
