import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import 'suppliers_controller.dart';
import 'supplier_model.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SuppliersController>(context, listen: false).loadSuppliers();
    });
  }

  Future<bool> _showSupplierDialog({
    required String title,
    Supplier? supplier,
  }) async {
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final locationController =
        TextEditingController(text: supplier?.location ?? '');
    final emailController =
        TextEditingController(text: supplier?.email ?? '');
    final businessController =
        TextEditingController(text: supplier?.businessName ?? '');

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
                  label: AppStrings.supplierName,
                  hint: 'Enter supplier name',
                  controller: nameController,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: AppStrings.phoneNumber,
                  hint: 'Enter phone number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: AppStrings.location,
                  hint: 'Enter location',
                  controller: locationController,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: 'Email (optional)',
                  hint: 'Enter email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: 'Business name (optional)',
                  hint: 'Enter business name',
                  controller: businessController,
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

    final controller = Provider.of<SuppliersController>(
      context,
      listen: false,
    );
    final success = supplier == null
        ? await controller.addSupplier(
            name: nameController.text.trim(),
            phone: phoneController.text.trim(),
            location: locationController.text.trim(),
            email: emailController.text.trim().isEmpty
                ? null
                : emailController.text.trim(),
            businessName: businessController.text.trim().isEmpty
                ? null
                : businessController.text.trim(),
          )
        : await controller.updateSupplier(
            supplier.copyWith(
              name: nameController.text.trim(),
              phone: phoneController.text.trim(),
              location: locationController.text.trim(),
              email: emailController.text.trim().isEmpty
                  ? null
                  : emailController.text.trim(),
              businessName: businessController.text.trim().isEmpty
                  ? null
                  : businessController.text.trim(),
            ),
          );

    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (supplier == null
                  ? AppStrings.supplierAdded
                  : 'Supplier updated')
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
        title: const Text(AppStrings.suppliersTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SuppliersController>(
                context,
                listen: false,
              ).loadSuppliers();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSupplierDialog(title: AppStrings.addSupplier);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Consumer<SuppliersController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final content = controller.suppliers.isEmpty
              ? const Center(
                  child: Text('No suppliers yet. Add your first supplier.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = controller.suppliers[index];
                    return _buildSupplierTile(supplier);
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

  Widget _buildSupplierTile(Supplier supplier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${supplier.phone} • ${supplier.location}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await _showSupplierDialog(
                title: 'Edit Supplier',
                supplier: supplier,
              );
            }
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Supplier'),
                    content: Text('Delete ${supplier.name}?'),
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
                final controller = Provider.of<SuppliersController>(
                  context,
                  listen: false,
                );
                final success = await controller.deleteSupplier(supplier.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Supplier deleted'
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
      ),
    );
  }
}
