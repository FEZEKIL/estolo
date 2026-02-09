class Sale {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double totalPrice;
  final DateTime date;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.date,
  });

  // Convert Sale to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
      'date': date.toIso8601String(),
    };
  }

  // Create Sale from Map
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      totalPrice: map['totalPrice'].toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  // Create copy with updated values
  Sale copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    double? totalPrice,
    DateTime? date,
  }) {
    return Sale(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      date: date ?? this.date,
    );
  }
}
