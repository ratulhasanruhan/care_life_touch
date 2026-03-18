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
    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: (json['productId'] ?? json['product'] ?? json['product_id'] ?? '').toString(),
      reviewerName: (json['reviewerName'] ?? json['userName'] ?? json['name'] ?? 'Anonymous').toString(),
      reviewerImage: (json['reviewerImage'] ?? json['userImage'] ?? json['avatar']).toString(),
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
      return value.map((e) => e.toString()).toList();
    }
    return [];
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

