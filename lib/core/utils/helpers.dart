import 'package:intl/intl.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_ZA',
      symbol: 'R',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd MMM yyyy HH:mm');
    return formatter.format(dateTime);
  }

  // Format phone number for dialing
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Add country code if not present
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '+27${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+27$cleanNumber';
    }

    return cleanNumber;
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^(\+27|0)[6-8][0-9]{8}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'\s+'), ''));
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Calculate total price
  static double calculateTotalPrice(int quantity, double price) {
    return quantity * price;
  }

  // Check if stock is low
  static bool isLowStock(int stock, {int threshold = 10}) {
    return stock <= threshold;
  }

  // Check if out of stock
  static bool isOutOfStock(int stock) {
    return stock <= 0;
  }

  // Format stock status
  static String getStockStatus(int stock) {
    if (isOutOfStock(stock)) return 'Out of Stock';
    if (isLowStock(stock)) return 'Low Stock';
    return 'In Stock';
  }

  // Calculate percentage
  static double calculatePercentage(int value, int total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }
}
