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
      productId: (json['productId'] ?? json['product'] ?? json['product_id'] ?? '').toString(),
      productName: (json['productName'] ?? json['name'] ?? '').toString(),
      price: _toDouble(json['price'] ?? 0),
      imagePath: (json['imagePath'] ?? json['image'] ?? json['imageUrl']).toString(),
      brand: (json['brand'] ?? '').toString(),
      rating: _toDouble(json['rating'] ?? json['rate'] ?? 0),
      addedAt: json['addedAt'] != null ? DateTime.tryParse(json['addedAt'].toString()) : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
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
        ? itemsRaw.map((item) {
            if (item is Map<String, dynamic>) {
              return WishlistItem.fromJson(item);
            }
            return null;
          }).whereType<WishlistItem>().toList()
        : <WishlistItem>[];

    return WishlistSnapshot(
      items: items,
      totalCount: (json['totalCount'] ?? json['total'] ?? json['count'] ?? items.length) as int,
      success: json['success'] == true || json['status'] == 'success',
      message: (json['message'] ?? json['msg']).toString(),
    );
  }
}

