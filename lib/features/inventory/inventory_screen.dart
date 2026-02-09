import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import 'inventory_controller.dart';
import 'product_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryController>(context, listen: false).loadProducts();
    });
  }

  Future<bool> _showProductDialog({
    required String title,
    Product? product,
  }) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final stockController = TextEditingController(
      text: product != null ? product.stock.toString() : '',
    );
    final priceController = TextEditingController(
      text: product != null ? product.price.toString() : '',
    );
    final barcodeController =
        TextEditingController(text: product?.barcode ?? '');
    final categoryController =
        TextEditingController(text: product?.category ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInput(
                  label: AppStrings.productName,
                  hint: AppStrings.productNameHint,
                  controller: nameController,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: AppStrings.stockQuantity,
                  hint: 'Enter stock quantity',
                  controller: stockController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: AppStrings.productPrice,
                  hint: 'Enter price',
                  controller: priceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: 'Barcode (optional)',
                  hint: 'Enter barcode',
                  controller: barcodeController,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: 'Category (optional)',
                  hint: 'Enter category',
                  controller: categoryController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );

    if (result != true) return false;

    final name = nameController.text.trim();
    final stock = int.tryParse(stockController.text.trim()) ?? 0;
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final barcode = barcodeController.text.trim();
    final category = categoryController.text.trim();

    final controller = Provider.of<InventoryController>(
      context,
      listen: false,
    );
    final success = product == null
        ? await controller.addProduct(
            name: name,
            stock: stock,
            price: price,
            barcode: barcode.isEmpty ? null : barcode,
            category: category.isEmpty ? null : category,
          )
        : await controller.updateProduct(
            product.copyWith(
              name: name,
              stock: stock,
              price: price,
              barcode: barcode.isEmpty ? null : barcode,
              category: category.isEmpty ? null : category,
            ),
          );

    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (product == null
                  ? AppStrings.productAdded
                  : 'Product updated')
              : (controller.errorMessage ?? ''),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
    return success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.inventoryTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<InventoryController>(
                context,
                listen: false,
              ).loadProducts();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductDialog(title: AppStrings.addProduct);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Consumer<InventoryController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final content = controller.products.isEmpty
              ? const Center(
                  child: Text('No products yet. Add your first product.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _buildProductTile(product);
                  },
                );

          if (controller.errorMessage == null) {
            return content;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.error.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
                child: Text(
                  controller.errorMessage ?? '',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductTile(Product product) {
    final statusColor = product.isOutOfStock()
        ? AppColors.error
        : product.isLowStock()
        ? AppColors.warning
        : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${Helpers.formatCurrency(product.price)} • Stock: ${product.stock}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.getStockStatus(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.warning,
              onPressed: product.stock <= 0
                  ? null
                  : () async {
                      final controller = Provider.of<InventoryController>(
                        context,
                        listen: false,
                      );
                      await controller.updateProduct(
                        product.copyWith(stock: product.stock - 1),
                      );
                    },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.success,
              onPressed: () async {
                final controller = Provider.of<InventoryController>(
                  context,
                  listen: false,
                );
                await controller.updateProduct(
                  product.copyWith(stock: product.stock + 1),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  await _showProductDialog(
                    title: 'Edit Product',
                    product: product,
                  );
                }
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Product'),
                        content: Text('Delete ${product.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(AppStrings.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(AppStrings.delete),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    final controller = Provider.of<InventoryController>(
                      context,
                      listen: false,
                    );
                    final success = await controller.deleteProduct(product.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Product deleted'
                              : (controller.errorMessage ?? ''),
                        ),
                        backgroundColor:
                            success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text(AppStrings.edit),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(AppStrings.delete),
                ),
              ],
              child: const Icon(Icons.more_vert, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
