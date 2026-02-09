import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URL for backend API
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }
  
  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  
  // Product endpoints
  static const String productsEndpoint = '/products';
  static const String productByIdEndpoint = '/products/';
  
  // Sales endpoints
  static const String salesEndpoint = '/sales';
  static const String saleByIdEndpoint = '/sales/';
  
  // Supplier endpoints
  static const String suppliersEndpoint = '/suppliers';
  static const String supplierByIdEndpoint = '/suppliers/';
  
  // Analytics endpoints
  static const String demandPredictionEndpoint = '/analytics/demand';
  
  // Timeout durations
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
