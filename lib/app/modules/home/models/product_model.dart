/// Product Model
class ProductModel {
  final String id;
  final String? slug;
  final String? defaultVariantId;
  final String name;
  final String? brandId;
  final String brand;
  final String categoryName;
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
    this.brandId,
    required this.brand,
    this.categoryName = '',
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

  bool get hasRemoteImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  /// Get price display string
  String get priceDisplay {
    if (maxPrice != null) {
      return '৳${_formatMoney(price)}-৳${_formatMoney(maxPrice!)}';
    }
    return '৳${_formatMoney(price)}';
  }

  /// Get MOQ display string
  String get moqDisplay => 'MOQ $moq';

  /// Factory method to create from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final categoryName = (json['category'] is Map)
        ? (json['category']['name'] ?? '').toString()
        : '';
    final variants = json['variants'] is List
        ? (json['variants'] as List)
        : const [];
    final firstVariant = variants.isNotEmpty && variants.first is Map
        ? (variants.first as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          )
        : const <String, dynamic>{};
    final rawVariantId =
        json['defaultVariantId'] ??
        json['variantId'] ??
        firstVariant['_id'] ??
        firstVariant['id'];
    final defaultVariantId = rawVariantId?.toString().trim();
    final imageList = <String>[];
    final images = json['images'];
    if (images is List) {
      for (final image in images) {
        if (image is Map &&
            image['url'] is String &&
            (image['url'] as String).trim().isNotEmpty) {
          imageList.add((image['url'] as String).trim());
        }
      }
    }

    final thumbnail = (json['thumbnail'] ?? json['imagePath'] ?? '').toString();
    final primaryImage = imageList.isNotEmpty
        ? imageList.first
        : (thumbnail.isNotEmpty ? thumbnail : 'assets/demo/product_1.png');

    final finalPrice = _toDouble(json['finalPrice'] ?? json['price']) ?? 0;
    final comparePrice = _toDouble(json['comparePrice']);
    final ratingValue = (json['ratings'] is Map)
        ? json['ratings']['average']
        : json['rating'];
    final discount = json['discount'];
    final discountValue = discount is Map ? (discount['value'] ?? 0) : 0;

    final rawBrandValue = json['brand'];
    final brandIdFromObject = (rawBrandValue is Map)
        ? (rawBrandValue['_id'] ?? rawBrandValue['id'])?.toString().trim()
        : null;
    final brandIdFromField = (json['brandId'] ?? '').toString().trim();
    final brandIdFromRaw = rawBrandValue is String ? rawBrandValue.trim() : '';

    final resolvedBrandId = _isValidBrandId(brandIdFromObject)
        ? brandIdFromObject!
        : _isValidBrandId(brandIdFromField)
        ? brandIdFromField
        : _isValidBrandId(brandIdFromRaw)
        ? brandIdFromRaw
        : '';

    return ProductModel(
      id: id,
      slug: (json['slug'] ?? '').toString().isEmpty
          ? null
          : json['slug'].toString(),
      defaultVariantId: defaultVariantId == null || defaultVariantId.isEmpty
          ? null
          : defaultVariantId,
      name: json['name'] ?? '',
      brandId: resolvedBrandId.isEmpty ? null : resolvedBrandId,
      brand: _resolveBrandText(json),
      categoryName: categoryName,
      description: (json['description'] ?? json['shortDescription'])
          ?.toString(),
      price: finalPrice,
      maxPrice: comparePrice,
      moq: variants.isNotEmpty
          ? (firstVariant['unit'] ?? firstVariant['packSize'] ?? '1 unit')
                .toString()
          : '1 unit',
      rating: (ratingValue is num) ? ratingValue.toDouble() : 4.9,
      imagePath: primaryImage,
      imageUrls: imageList,
      hasOffer:
          (discountValue is num ? discountValue > 0 : false) ||
          (comparePrice != null && comparePrice > finalPrice + 0.0001),
      offerLabel: (discountValue is num && discountValue > 0)
          ? '${discountValue.toInt()} OFF'
          : json['offerLabel'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return double.tryParse(text);
  }

  static String _formatMoney(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  static String _resolveBrandText(Map<String, dynamic> json) {
    final brandValue = json['brand'];

    if (brandValue is Map) {
      final name = (brandValue['name'] ?? '').toString().trim();
      if (_isValidBrand(name)) {
        return name;
      }
    }

    final brandName = (json['brandName'] ?? json['brand_name'] ?? '')
        .toString()
        .trim();
    if (_isValidBrand(brandName)) {
      return brandName;
    }

    final manufacturer = (json['manufacturer'] ?? '').toString().trim();
    if (_isValidBrand(manufacturer)) {
      return manufacturer;
    }

    final brandText = brandValue?.toString().trim() ?? '';
    if (_isValidBrand(brandText)) {
      return brandText;
    }

    return 'Unknown brand';
  }

  static bool _isValidBrand(String value) {
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return false;
    }
    return !RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
  }

  static bool _isValidBrandId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return false;
    }
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(text);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'defaultVariantId': defaultVariantId,
      'name': name,
      'brandId': brandId,
      'brand': brand,
      'categoryName': categoryName,
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
