import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _usersKey = 'users';
  static const String _productsKey = 'products';
  static const String _salesKey = 'sales';
  static const String _suppliersKey = 'suppliers';

  // Auth methods
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    // Don't remove user data - it should persist between sessions
  }

  // User data methods
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    print('Saving user data with key: $_userDataKey');
    print('User data to save: $userData');
    await prefs.setString(_userDataKey, jsonEncode(userData));
    print('User data saved successfully');
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    print('Getting user data with key: $_userDataKey');
    final data = prefs.getString(_userDataKey);
    print('Retrieved data: $data');
    if (data != null) {
      final decoded = jsonDecode(data);
      print('Decoded user data: $decoded');
      return decoded;
    }
    print('No user data found');
    return null;
  }

  // Users management methods
  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<List<Map<String, dynamic>>?> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_usersKey);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return null;
  }

  // Products methods
  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(products));
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_productsKey);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  // Sales methods
  Future<void> saveSales(List<Map<String, dynamic>> sales) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_salesKey, jsonEncode(sales));
  }

  Future<List<Map<String, dynamic>>> getSales() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_salesKey);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  // Suppliers methods
  Future<void> saveSuppliers(List<Map<String, dynamic>> suppliers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_suppliersKey, jsonEncode(suppliers));
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_suppliersKey);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
