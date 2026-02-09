import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import 'product_model.dart';

class InventoryController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Uuid _uuid = Uuid();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalProducts => _products.length;
  int get lowStockCount =>
      _products.where((product) => product.isLowStock()).length;
  int get outOfStockCount =>
      _products.where((product) => product.isOutOfStock()).length;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.productsEndpoint);
      final data = (response as List?) ?? [];
      _products = data.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return Product(
          id: map['id'],
          name: map['name'],
          stock: map['stock'],
          price: (map['price'] as num).toDouble(),
          barcode: map['barcode'],
          category: map['category'],
          createdAt: DateTime.parse(map['created_at']),
        );
      }).toList();
      _products.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct({
    required String name,
    required int stock,
    required double price,
    String? barcode,
    String? category,
  }) async {
    if (name.isEmpty || stock < 0 || price < 0) {
      _errorMessage = 'Invalid product data';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = Product(
        id: _uuid.v4(),
        name: name,
        stock: stock,
        price: price,
        barcode: barcode,
        category: category,
        createdAt: DateTime.now(),
      );

      await _apiService.post(ApiConstants.productsEndpoint, {
        'id': product.id,
        'name': product.name,
        'stock': product.stock,
        'price': product.price,
        'barcode': product.barcode,
        'category': product.category,
        'created_at': product.createdAt.toIso8601String(),
      });

      // Reload products
      await loadProducts();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint =
          '${ApiConstants.productByIdEndpoint}${updatedProduct.id}';
      await _apiService.put(endpoint, {
        'id': updatedProduct.id,
        'name': updatedProduct.name,
        'stock': updatedProduct.stock,
        'price': updatedProduct.price,
        'barcode': updatedProduct.barcode,
        'category': updatedProduct.category,
        'created_at': updatedProduct.createdAt.toIso8601String(),
      });
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = '${ApiConstants.productByIdEndpoint}$productId';
      await _apiService.delete(endpoint);
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Product? findProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
          (product.barcode?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (product.category?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<Product> getLowStockProducts({int threshold = 10}) {
    return _products
        .where((product) => product.isLowStock(threshold: threshold))
        .toList();
  }

  List<Product> getOutOfStockProducts() {
    return _products.where((product) => product.isOutOfStock()).toList();
  }

  double getTotalInventoryValue() {
    return _products.fold(
      0,
      (sum, product) => sum + (product.price * product.stock),
    );
  }
}
