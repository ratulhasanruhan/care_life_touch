class WishlistItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final String? imagePath;
  final String brand;
  final double rating;
  final DateTime? addedAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    this.imagePath,
    required this.brand,
    this.rating = 0,
    this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId:
          (json['productId'] ?? json['product'] ?? json['product_id'] ?? '')
              .toString(),
      productName: (json['productName'] ?? json['name'] ?? '').toString(),
      price: _toDouble(json['price'] ?? 0),
      imagePath: _toNullableString(
        json['imagePath'] ?? json['image'] ?? json['imageUrl'],
      ),
      brand: (json['brand'] ?? '').toString(),
      rating: _toDouble(json['rating'] ?? json['rate'] ?? 0),
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt'].toString())
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'imagePath': imagePath,
      'brand': brand,
      'rating': rating,
      'addedAt': addedAt?.toIso8601String(),
    };
  }
}

class WishlistSnapshot {
  final List<WishlistItem> items;
  final int totalCount;
  final bool success;
  final String? message;

  WishlistSnapshot({
    required this.items,
    this.totalCount = 0,
    this.success = true,
    this.message,
  });

  bool get isEmpty => items.isEmpty;

  factory WishlistSnapshot.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['data'] ?? json['wishlist'] ?? json['items'] ?? [];
    final items = (itemsRaw is List)
        ? itemsRaw
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return WishlistItem.fromJson(item);
                }
                if (item is Map) {
                  return WishlistItem.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  );
                }
                return null;
              })
              .whereType<WishlistItem>()
              .toList()
        : <WishlistItem>[];

    return WishlistSnapshot(
      items: items,
      totalCount: _toInt(
        json['totalCount'] ?? json['total'] ?? json['count'] ?? items.length,
      ),
      success: json['success'] == true || json['status'] == 'success',
      message: _toNullableString(json['message'] ?? json['msg']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }
}
