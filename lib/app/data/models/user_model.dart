/// Base model class that all models should extend
abstract class BaseModel {
  /// Convert model to JSON
  Map<String, dynamic> toJson();

  /// Create model from JSON
  /// This should be implemented by child classes
}

/// User Model
class User extends BaseModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? shopName;
  final String? ownerName;
  final String? profileImage;
  final String? address;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.shopName,
    this.ownerName,
    this.profileImage,
    this.address,
    this.createdAt,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    final name = (json['ownerName'] ?? json['fullName'] ?? json['name'] ?? '').toString();
    return User(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: name,
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      shopName: json['shopName']?.toString(),
      ownerName: json['ownerName']?.toString() ?? (name.isEmpty ? null : name),
      profileImage: (json['profileImage'] ??
              json['profile_image'] ??
              json['shopImage'] ??
              json['shop_image'])
          ?.toString(),
      address: (json['address'] ?? json['fullAddress'])?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'])
                : null),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'shopName': shopName,
      'ownerName': ownerName,
      'profileImage': profileImage,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Copy with method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? shopName,
    String? ownerName,
    String? profileImage,
    String? address,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
