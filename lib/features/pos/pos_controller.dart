import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import 'sale_model.dart';
import '../inventory/product_model.dart';

class PosController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Uuid _uuid = Uuid();

  List<Product> _cartItems = [];
  List<Sale> _recentSales = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get cartItems => _cartItems;
  List<Sale> get recentSales => _recentSales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.stock));

  Future<void> loadRecentSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.salesEndpoint);
      final data = (response as List?) ?? [];
      _recentSales = data.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return Sale(
          id: map['id'],
          productId: map['product_id'],
          productName: map['product_name'],
          quantity: map['quantity'],
          price: (map['price'] as num).toDouble(),
          totalPrice: (map['total_price'] as num).toDouble(),
          date: DateTime.parse(map['date']),
        );
      }).toList();
      _recentSales.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort by newest first
    } catch (e) {
      _errorMessage = 'Failed to load sales: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(Product product, int quantity) {
    if (quantity <= 0) return;

    if (quantity > product.stock) {
      _errorMessage = 'Insufficient stock available';
      notifyListeners();
      return;
    }

    // Check if product already in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item.id == product.id,
    );

    if (existingIndex != -1) {
      // Update existing item
      final updatedItem = _cartItems[existingIndex].copyWith(
        stock: _cartItems[existingIndex].stock + quantity,
      );
      _cartItems[existingIndex] = updatedItem;
    } else {
      // Add new item
      final cartProduct = product.copyWith(stock: quantity);
      _cartItems.add(cartProduct);
    }

    _errorMessage = null;
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        removeFromCart(productId);
      } else {
        final maxStock = getProductOriginalStock(productId);
        if (newQuantity <= maxStock) {
          _cartItems[index] = _cartItems[index].copyWith(stock: newQuantity);
          _errorMessage = null;
        } else {
          _errorMessage = 'Quantity exceeds available stock';
        }
      }
      notifyListeners();
    }
  }

  int getProductOriginalStock(String productId) {
    // This would typically come from inventory service
    // For now, returning a default value
    return 100;
  }

  Future<bool> checkout() async {
    if (_cartItems.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();

      for (final cartItem in _cartItems) {
        final sale = Sale(
          id: _uuid.v4(),
          productId: cartItem.id,
          productName: cartItem.name,
          quantity: cartItem.stock,
          price: cartItem.price,
          totalPrice: cartItem.price * cartItem.stock,
          date: now,
        );
        await _apiService.post(ApiConstants.salesEndpoint, {
          'id': sale.id,
          'product_id': sale.productId,
          'product_name': sale.productName,
          'quantity': sale.quantity,
          'price': sale.price,
          'total_price': sale.totalPrice,
          'date': sale.date.toIso8601String(),
        });
      }

      // Clear cart
      _cartItems.clear();

      // Reload recent sales
      await loadRecentSales();

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Checkout failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSale(Sale updatedSale) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = '${ApiConstants.saleByIdEndpoint}${updatedSale.id}';
      await _apiService.put(endpoint, {
        'id': updatedSale.id,
        'product_id': updatedSale.productId,
        'product_name': updatedSale.productName,
        'quantity': updatedSale.quantity,
        'price': updatedSale.price,
        'total_price': updatedSale.totalPrice,
        'date': updatedSale.date.toIso8601String(),
      });
      await loadRecentSales();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update sale: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSale(String saleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = '${ApiConstants.saleByIdEndpoint}$saleId';
      await _apiService.delete(endpoint);
      await loadRecentSales();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete sale: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  int getCartItemCount() {
    return _cartItems.fold(0, (sum, item) => sum + item.stock);
  }
}
