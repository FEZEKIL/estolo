import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json', ...?headers},
            body: jsonEncode(data),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json', ...?headers})
          .timeout(const Duration(milliseconds: ApiConstants.receiveTimeout));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .put(
            url,
            headers: {'Content-Type': 'application/json', ...?headers},
            body: jsonEncode(data),
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  Future<bool> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .delete(
            url,
            headers: {'Content-Type': 'application/json', ...?headers},
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }
}
