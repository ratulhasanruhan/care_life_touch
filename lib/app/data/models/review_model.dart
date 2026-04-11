class ReviewModel {
  final String id;
  final String productId;
  final String reviewerName;
  final String? reviewerImage;
  final double rating;
  final String reviewText;
  final List<String>? images;
  final int? helpfulCount;
  final DateTime? createdAt;
  final bool? isVerifiedPurchase;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.reviewerName,
    this.reviewerImage,
    required this.rating,
    required this.reviewText,
    this.images,
    this.helpfulCount,
    this.createdAt,
    this.isVerifiedPurchase,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final reviewer = _toMap(json['reviewer']) ?? _toMap(json['user']);
    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: (json['productId'] ?? json['product'] ?? json['product_id'] ?? '').toString(),
      reviewerName: _firstNonEmptyString([
        json['reviewerName'],
        json['userName'],
        json['name'],
        reviewer?['name'],
        reviewer?['fullName'],
      ]) ??
          'Anonymous',
      reviewerImage: _firstNonEmptyString([
        json['reviewerImage'],
        json['userImage'],
        json['avatar'],
        reviewer?['profileImage'],
        reviewer?['avatar'],
      ]),
      rating: _toDouble(json['rating'] ?? json['rate'] ?? 0),
      reviewText: (json['reviewText'] ?? json['comment'] ?? json['review'] ?? '').toString(),
      images: _toStringList(json['images'] ?? json['reviewImages'] ?? []),
      helpfulCount: (json['helpfulCount'] ?? json['helpful'] ?? json['likes'] ?? 0) as int?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? json['verified'] ?? false,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) {
            if (e is Map) {
              return _firstNonEmptyString([e['url'], e['image'], e['path']]);
            }
            return _firstNonEmptyString([e]);
          })
          .whereType<String>()
          .toList();
    }
    return [];
  }

  static String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'reviewerName': reviewerName,
      'reviewerImage': reviewerImage,
      'rating': rating,
      'reviewText': reviewText,
      'images': images,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt?.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }
}

