import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/helpers.dart';
import '../pos/pos_controller.dart';
import '../pos/sale_model.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int _daysFilter = 0;
  String _productFilter = 'All products';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PosController>(context, listen: false).loadRecentSales();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Sale> _filterSales(List<Sale> sales) {
    var filtered = sales;
    if (_daysFilter > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: _daysFilter));
      filtered = filtered.where((s) => s.date.isAfter(cutoff)).toList();
    }
    if (_productFilter != 'All products') {
      filtered = filtered
          .where((s) => s.productName == _productFilter)
          .toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = filtered
          .where((s) => s.productName.toLowerCase().contains(q))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PosController>(context, listen: false)
                  .loadRecentSales();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search product',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = value.trim();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Filter:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _daysFilter,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('All time')),
                        DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                        DropdownMenuItem(value: 30, child: Text('Last 30 days')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _daysFilter = value;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text('Product:'),
                    const SizedBox(width: 12),
                    Consumer<PosController>(
                      builder: (context, posController, child) {
                        final products = posController.recentSales
                            .map((s) => s.productName)
                            .toSet()
                            .toList()
                          ..sort();
                        final items = [
                          'All products',
                          ...products,
                        ];
                        if (!items.contains(_productFilter)) {
                          _productFilter = 'All products';
                        }
                        return DropdownButton<String>(
                          value: _productFilter,
                          items: items
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _productFilter = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PosController>(
              builder: (context, posController, child) {
                if (posController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = _filterSales(posController.recentSales);
                final totalSales = filtered.fold<double>(
                  0,
                  (sum, sale) => sum + sale.totalPrice,
                );
                final totalItems = filtered.fold<int>(
                  0,
                  (sum, sale) => sum + sale.quantity,
                );

                final errorMessage = posController.errorMessage;

                return Column(
                  children: [
                    if (errorMessage != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        color: AppColors.error.withOpacity(0.1),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${Helpers.formatCurrency(totalSales)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Items: $totalItems',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              final csv = _buildCsv(filtered);
                              await Clipboard.setData(
                                ClipboardData(text: csv),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('CSV copied to clipboard'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Export CSV'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text(AppStrings.noData))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final sale = filtered[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.receipt,
                                      color: AppColors.primary,
                                    ),
                                    title: Text(
                                      sale.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${sale.quantity} items • ${Helpers.formatDateTime(sale.date)}',
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          final qtyController =
                                              TextEditingController(
                                            text: sale.quantity.toString(),
                                          );
                                          final result =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Edit Sale Quantity',
                                                ),
                                                content: TextField(
                                                  controller: qtyController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Quantity',
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: const Text(
                                                      AppStrings.cancel,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    child: const Text(
                                                      AppStrings.save,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (result == true) {
                                            final newQty = int.tryParse(
                                                  qtyController.text,
                                                ) ??
                                                sale.quantity;
                                            final updatedSale =
                                                sale.copyWith(
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
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? 'Sale updated'
                                                      : (posController
                                                              .errorMessage ??
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
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Delete Sale'),
                                                content: Text(
                                                  'Delete ${sale.productName} sale?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: const Text(
                                                      AppStrings.cancel,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    child: const Text(
                                                      AppStrings.delete,
                                                    ),
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
                                                await posController.deleteSale(
                                              sale.id,
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? 'Sale deleted'
                                                      : (posController
                                                              .errorMessage ??
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
                                            Helpers.formatCurrency(
                                              sale.totalPrice,
                                            ),
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

  String _buildCsv(List<Sale> sales) {
    final buffer = StringBuffer();
    buffer.writeln('product,quantity,price,total,date');
    for (final sale in sales) {
      buffer.writeln(
        '"${sale.productName}",${sale.quantity},${sale.price},${sale.totalPrice},${sale.date.toIso8601String()}',
      );
    }
    return buffer.toString();
  }
}
