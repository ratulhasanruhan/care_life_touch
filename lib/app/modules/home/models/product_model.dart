/// Product Model
class ProductModel {
  final String id;
  final String? slug;
  final String? defaultVariantId;
  final String name;
  final String brand;
  final String? description;
  final double price;
  final double? maxPrice;
  final String moq;
  final double rating;
  final String imagePath;
  final List<String> imageUrls;
  final bool hasOffer;
  final String? offerLabel;

  ProductModel({
    required this.id,
    this.slug,
    this.defaultVariantId,
    required this.name,
    required this.brand,
    this.description,
    required this.price,
    this.maxPrice,
    required this.moq,
    this.rating = 4.9,
    required this.imagePath,
    this.imageUrls = const [],
    this.hasOffer = false,
    this.offerLabel,
  });

  bool get hasRemoteImage => imagePath.startsWith('http://') || imagePath.startsWith('https://');

  /// Get price display string
  String get priceDisplay {
    if (maxPrice != null) {
      return '৳${price.toInt()}-৳${maxPrice!.toInt()}';
    }
    return '৳${price.toInt()}';
  }

  /// Get MOQ display string
  String get moqDisplay => 'MOQ $moq';

  /// Factory method to create from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final categoryName = (json['category'] is Map)
        ? (json['category']['name'] ?? '').toString()
        : '';
    final variants = json['variants'] is List ? (json['variants'] as List) : const [];
    final firstVariant = variants.isNotEmpty && variants.first is Map
        ? (variants.first as Map).map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};
    final rawVariantId =
        json['defaultVariantId'] ?? json['variantId'] ?? firstVariant['_id'] ?? firstVariant['id'];
    final defaultVariantId = rawVariantId?.toString().trim();
    final imageList = <String>[];
    final images = json['images'];
    if (images is List) {
      for (final image in images) {
        if (image is Map && image['url'] is String && (image['url'] as String).trim().isNotEmpty) {
          imageList.add((image['url'] as String).trim());
        }
      }
    }

    final thumbnail = (json['thumbnail'] ?? json['imagePath'] ?? '').toString();
    final primaryImage = imageList.isNotEmpty
        ? imageList.first
        : (thumbnail.isNotEmpty ? thumbnail : 'assets/demo/product_1.png');

    final finalPrice = (json['finalPrice'] ?? json['price'] ?? 0);
    final comparePrice = json['comparePrice'];
    final ratingValue = (json['ratings'] is Map)
        ? json['ratings']['average']
        : json['rating'];
    final discount = json['discount'];
    final discountValue = discount is Map ? (discount['value'] ?? 0) : 0;

    return ProductModel(
      id: id,
      slug: (json['slug'] ?? '').toString().isEmpty ? null : json['slug'].toString(),
      defaultVariantId: defaultVariantId == null || defaultVariantId.isEmpty
          ? null
          : defaultVariantId,
      name: json['name'] ?? '',
      brand: _resolveBrandName(json),
      description: (json['description'] ?? json['shortDescription'])?.toString(),
      price: (finalPrice is num) ? finalPrice.toDouble() : 0,
      maxPrice: comparePrice is num ? comparePrice.toDouble() : null,
      moq: variants.isNotEmpty
          ? (firstVariant['unit'] ?? firstVariant['packSize'] ?? '1 unit').toString()
          : (categoryName.isNotEmpty ? categoryName : '1 unit'),
      rating: (ratingValue is num) ? ratingValue.toDouble() : 4.9,
      imagePath: primaryImage,
      imageUrls: imageList,
      hasOffer: (discountValue is num ? discountValue > 0 : false) || (comparePrice is num && comparePrice > (finalPrice is num ? finalPrice : 0)),
      offerLabel: (discountValue is num && discountValue > 0)
          ? '${discountValue.toInt()} OFF'
          : json['offerLabel'],
    );
  }

  static String _resolveBrandName(Map<String, dynamic> json) {
    final brandValue = json['brand'];

    if (brandValue is Map) {
      final nestedCandidates = <dynamic>[
        brandValue['name'],
        brandValue['brandName'],
        brandValue['title'],
      ];
      for (final candidate in nestedCandidates) {
        final value = candidate?.toString().trim() ?? '';
        if (_isValidBrandText(value)) {
          return value;
        }
      }
    }

    final directNameCandidates = <dynamic>[
      json['brandName'],
      json['brand_name'],
      json['manufacturer'],
      brandValue,
    ];

    for (final candidate in directNameCandidates) {
      final value = candidate?.toString().trim() ?? '';
      if (_isValidBrandText(value)) {
        return value;
      }
    }

    return 'Unknown brand';
  }

  static bool _isValidBrandText(String value) {
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return false;
    }
    return !_looksLikeMongoId(value);
  }

  static bool _looksLikeMongoId(String value) {
    final regex = RegExp(r'^[a-fA-F0-9]{24}$');
    return regex.hasMatch(value);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'defaultVariantId': defaultVariantId,
      'name': name,
      'brand': brand,
      'description': description,
      'price': price,
      'maxPrice': maxPrice,
      'moq': moq,
      'rating': rating,
      'imagePath': imagePath,
      'imageUrls': imageUrls,
      'hasOffer': hasOffer,
      'offerLabel': offerLabel,
    };
  }
}
