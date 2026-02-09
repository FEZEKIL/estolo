class Supplier {
  final String id;
  final String name;
  final String phone;
  final String location;
  final String? email;
  final String? businessName;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    this.email,
    this.businessName,
    required this.createdAt,
  });

  // Convert Supplier to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'location': location,
      'email': email,
      'businessName': businessName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Supplier from Map
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      location: map['location'],
      email: map['email'],
      businessName: map['businessName'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Create copy with updated values
  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? location,
    String? email,
    String? businessName,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get formatted phone number for calling
  String getFormattedPhone() {
    // Remove all non-digit characters
    String cleanNumber = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Add country code if not present
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '+27${cleanNumber.substring(1)}';
    } else if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+27$cleanNumber';
    }

    return cleanNumber;
  }

  // Get WhatsApp link
  String getWhatsAppLink() {
    final formattedPhone = getFormattedPhone().replaceAll('+', '');
    return 'https://wa.me/$formattedPhone';
  }
}
