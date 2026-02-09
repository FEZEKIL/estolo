import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import 'supplier_model.dart';
import '../../core/utils/helpers.dart';

class SuppliersController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Uuid _uuid = Uuid();

  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSuppliers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.suppliersEndpoint);
      final data = (response as List?) ?? [];
      _suppliers = data.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return Supplier(
          id: map['id'],
          name: map['name'],
          phone: map['phone'],
          location: map['location'],
          email: map['email'],
          businessName: map['business_name'],
          createdAt: DateTime.parse(map['created_at']),
        );
      }).toList();
      _suppliers.sort(
        (a, b) => a.name.compareTo(b.name),
      ); // Sort alphabetically
    } catch (e) {
      _errorMessage = 'Failed to load suppliers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSupplier({
    required String name,
    required String phone,
    required String location,
    String? email,
    String? businessName,
  }) async {
    if (name.isEmpty || phone.isEmpty || location.isEmpty) {
      _errorMessage = 'Name, phone, and location are required';
      notifyListeners();
      return false;
    }

    if (!Helpers.isValidPhoneNumber(phone)) {
      _errorMessage = 'Invalid phone number format';
      notifyListeners();
      return false;
    }

    if (email != null && email.isNotEmpty && !Helpers.isValidEmail(email)) {
      _errorMessage = 'Invalid email format';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final supplier = Supplier(
        id: _uuid.v4(),
        name: name,
        phone: phone,
        location: location,
        email: email,
        businessName: businessName,
        createdAt: DateTime.now(),
      );

      await _apiService.post(ApiConstants.suppliersEndpoint, {
        'id': supplier.id,
        'name': supplier.name,
        'phone': supplier.phone,
        'location': supplier.location,
        'email': supplier.email,
        'business_name': supplier.businessName,
        'created_at': supplier.createdAt.toIso8601String(),
      });

      // Reload suppliers
      await loadSuppliers();

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add supplier: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSupplier(Supplier updatedSupplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint =
          '${ApiConstants.supplierByIdEndpoint}${updatedSupplier.id}';
      await _apiService.put(endpoint, {
        'id': updatedSupplier.id,
        'name': updatedSupplier.name,
        'phone': updatedSupplier.phone,
        'location': updatedSupplier.location,
        'email': updatedSupplier.email,
        'business_name': updatedSupplier.businessName,
        'created_at': updatedSupplier.createdAt.toIso8601String(),
      });
      await loadSuppliers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update supplier: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSupplier(String supplierId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = '${ApiConstants.supplierByIdEndpoint}$supplierId';
      await _apiService.delete(endpoint);
      await loadSuppliers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete supplier: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Supplier? findSupplierById(String id) {
    try {
      return _suppliers.firstWhere((supplier) => supplier.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;

    final lowercaseQuery = query.toLowerCase();
    return _suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(lowercaseQuery) ||
          supplier.location.toLowerCase().contains(lowercaseQuery) ||
          (supplier.businessName?.toLowerCase().contains(lowercaseQuery) ??
              false);
    }).toList();
  }

  List<Supplier> getSuppliersByLocation(String location) {
    return _suppliers
        .where(
          (supplier) =>
              supplier.location.toLowerCase().contains(location.toLowerCase()),
        )
        .toList();
  }

  void callSupplier(String phoneNumber) {
    // This would integrate with phone calling functionality
    // For now, just print to console
    print('Calling: $phoneNumber');
  }

  void messageSupplier(String phoneNumber) {
    // This would integrate with messaging functionality
    // For now, just print to console
    print('Messaging: $phoneNumber');
  }
}
