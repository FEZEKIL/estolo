class Product {
  final String id;
  final String name;
  final int stock;
  final double price;
  final String? barcode;
  final String? category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    this.barcode,
    this.category,
    required this.createdAt,
  });

  // Convert Product to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'price': price,
      'barcode': barcode,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Product from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      stock: map['stock'],
      price: map['price'].toDouble(),
      barcode: map['barcode'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Create copy with updated values
  Product copyWith({
    String? id,
    String? name,
    int? stock,
    double? price,
    String? barcode,
    String? category,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if product is low stock
  bool isLowStock({int threshold = 10}) {
    return stock <= threshold;
  }

  // Check if product is out of stock
  bool isOutOfStock() {
    return stock <= 0;
  }

  // Get stock status
  String getStockStatus() {
    if (isOutOfStock()) return 'Out of Stock';
    if (isLowStock()) return 'Low Stock';
    return 'In Stock';
  }
}
