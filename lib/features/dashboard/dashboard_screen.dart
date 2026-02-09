import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/app_button.dart';
import '../pos/pos_controller.dart';
import '../inventory/inventory_controller.dart';
import '../analytics/demand_controller.dart';
import '../auth/auth_controller.dart';
import '../auth/login_screen.dart';
import '../pos/pos_screen.dart';
import '../inventory/inventory_screen.dart';
import '../suppliers/suppliers_screen.dart';
import '../analytics/analytics_screen.dart';
import '../sales/sales_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after the widget is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    Provider.of<PosController>(context, listen: false).loadRecentSales();
    Provider.of<InventoryController>(context, listen: false).loadProducts();
    Provider.of<DemandController>(context, listen: false).loadRecentSales();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform logout
                final authController = Provider.of<AuthController>(
                  context,
                  listen: false,
                );
                authController.logout();
                Navigator.of(context).pop(); // Close dialog

                // After logout, navigate back to login screen
                // We need to pop the dashboard screen as well
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          Consumer<AuthController>(
            builder: (context, authController, child) {
              final userData = authController.userData;
              final userName = userData?['name'] ?? 'User';
              return PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      'Welcome, $userName!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer3<PosController, InventoryController, DemandController>(
                builder:
                    (
                      context,
                      posController,
                      inventoryController,
                      demandController,
                      child,
                    ) {
                      final errors = [
                        posController.errorMessage,
                        inventoryController.errorMessage,
                        demandController.errorMessage,
                      ].where((e) => e != null && e.isNotEmpty).toList();

                      if (errors.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errors.join(' | '),
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    },
              ),
              // Summary Cards
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Consumer3<PosController, InventoryController, DemandController>(
                builder:
                    (
                      context,
                      posController,
                      inventoryController,
                      demandController,
                      child,
                    ) {
                      final today = DateTime.now();
                      final todaySales = posController.recentSales
                          .where(
                            (sale) =>
                                sale.date.day == today.day &&
                                sale.date.month == today.month &&
                                sale.date.year == today.year,
                          )
                          .fold(0.0, (sum, sale) => sum + sale.totalPrice);

                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          SummaryCard(
                            title: AppStrings.todaySales,
                            value: Helpers.formatCurrency(todaySales),
                            icon: Icons.attach_money,
                            iconColor: AppColors.success,
                            backgroundColor: AppColors.successLight.withOpacity(
                              0.2,
                            ),
                          ),
                          SummaryCard(
                            title: AppStrings.totalProducts,
                            value: inventoryController.totalProducts.toString(),
                            icon: Icons.inventory,
                            iconColor: AppColors.primary,
                            backgroundColor: AppColors.primaryLight.withOpacity(
                              0.2,
                            ),
                          ),
                          SummaryCard(
                            title: AppStrings.lowStockItems,
                            value: inventoryController.lowStockCount.toString(),
                            icon: Icons.warning,
                            iconColor: AppColors.warning,
                            backgroundColor: AppColors.warningLight.withOpacity(
                              0.2,
                            ),
                          ),
                          SummaryCard(
                            title: 'Total Value',
                            value: Helpers.formatCurrency(
                              inventoryController.getTotalInventoryValue(),
                            ),
                            subtitle: 'Inventory worth',
                            icon: Icons.account_balance_wallet,
                            iconColor: AppColors.secondary,
                            backgroundColor: AppColors.secondaryLight
                                .withOpacity(0.2),
                          ),
                        ],
                      );
                    },
              ),
              const SizedBox(height: 32),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildActionButton(
                    title: 'POS System',
                    icon: Icons.point_of_sale,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PosScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    title: 'Inventory',
                    icon: Icons.inventory_2,
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const InventoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    title: 'Suppliers',
                    icon: Icons.people,
                    color: AppColors.success,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SuppliersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    title: 'Analytics',
                    icon: Icons.analytics,
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Activity
              const Text(
                'Recent Sales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SalesHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<PosController>(
                builder: (context, posController, child) {
                  if (posController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (posController.recentSales.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: AppColors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No sales recorded yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start recording sales to see them here',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final recentSales = posController.recentSales
                      .take(5)
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentSales.length,
                    itemBuilder: (context, index) {
                      final sale = recentSales[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.receipt,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            sale.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${sale.quantity} items • ${Helpers.formatDateTime(sale.date)}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final qtyController = TextEditingController(
                                  text: sale.quantity.toString(),
                                );
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Edit Sale Quantity'),
                                      content: TextField(
                                        controller: qtyController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Quantity',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text(AppStrings.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text(AppStrings.save),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (result == true) {
                                  final newQty =
                                      int.tryParse(qtyController.text) ??
                                          sale.quantity;
                                  final updatedSale = sale.copyWith(
                                    quantity: newQty,
                                    totalPrice: sale.price * newQty,
                                  );
                                  final posController =
                                      Provider.of<PosController>(
                                    context,
                                    listen: false,
                                  );
                                  final success =
                                      await posController.updateSale(
                                    updatedSale,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Sale updated'
                                            : (posController.errorMessage ??
                                                ''),
                                      ),
                                      backgroundColor: success
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  );
                                }
                              }
                              if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Sale'),
                                      content: Text(
                                        'Delete ${sale.productName} sale?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text(AppStrings.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text(AppStrings.delete),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  final posController =
                                      Provider.of<PosController>(
                                    context,
                                    listen: false,
                                  );
                                  final success =
                                      await posController.deleteSale(sale.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Sale deleted'
                                            : (posController.errorMessage ??
                                                ''),
                                      ),
                                      backgroundColor: success
                                          ? AppColors.success
                                          : AppColors.error,
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  Helpers.formatCurrency(sale.totalPrice),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.more_vert,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
