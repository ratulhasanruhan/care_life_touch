class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final String date;
  final bool isVerifiedPurchase;
  final List<String> images;
  final int helpfulCount;
  bool isHelpful;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerifiedPurchase = false,
    this.images = const [],
    this.helpfulCount = 0,
    this.isHelpful = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      images: (json['images'] as List?)?.cast<String>() ?? [],
      helpfulCount: json['helpfulCount'] ?? 0,
      isHelpful: json['isHelpful'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date,
      'isVerifiedPurchase': isVerifiedPurchase,
      'images': images,
      'helpfulCount': helpfulCount,
      'isHelpful': isHelpful,
    };
  }
}

