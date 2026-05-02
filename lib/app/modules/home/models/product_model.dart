class ProductVariant {
  final String id;
  final String unit;
  final double? price;
  final double? comparePrice;

  const ProductVariant({
    required this.id,
    required this.unit,
    this.price,
    this.comparePrice,
  });
}

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
  final List<ProductVariant> variants;
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
    this.variants = const [],
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
    final List<dynamic> variantsRaw;
    if (json['variants'] is List) {
      variantsRaw = json['variants'] as List;
    } else if (json['variant'] is Map) {
      variantsRaw = [json['variant']];
    } else if (json['variant'] is List) {
      variantsRaw = json['variant'] as List;
    } else if (json['selectedVariant'] is Map) {
      variantsRaw = [json['selectedVariant']];
    } else if (json['defaultVariant'] is Map) {
      variantsRaw = [json['defaultVariant']];
    } else {
      variantsRaw = const [];
    }
    var variantMaps = variantsRaw
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
    // Some list endpoints return variants as ObjectId strings only (no embedded maps).
    if (variantMaps.isEmpty && variantsRaw.isNotEmpty) {
      final synthetic = <Map<String, dynamic>>[];
      for (final item in variantsRaw) {
        if (item is Map) continue;
        final s = item?.toString().trim() ?? '';
        if (s.isNotEmpty && s.toLowerCase() != 'null') {
          synthetic.add({'_id': s});
        }
      }
      variantMaps = synthetic;
    }
    final firstVariant = variantMaps.isNotEmpty
        ? variantMaps.first
        : const <String, dynamic>{};
    final variantStringField = json['variant'] is String
        ? json['variant']?.toString().trim()
        : null;
    final defaultVariantStringField = json['defaultVariant'] is String
        ? json['defaultVariant']?.toString().trim()
        : null;
    final rawVariantId =
        json['defaultVariantId'] ??
        json['default_variant_id'] ??
        json['variantId'] ??
        json['variant_id'] ??
        (variantStringField?.isNotEmpty == true ? variantStringField : null) ??
        (defaultVariantStringField?.isNotEmpty == true
            ? defaultVariantStringField
            : null) ??
        firstVariant['_id'] ??
        firstVariant['id'] ??
        firstVariant['variantId'];
    final defaultVariantId = rawVariantId?.toString().trim();

    final parsedVariants = variantMaps
        .map(
          (variant) => ProductVariant(
            id: (variant['_id'] ??
                    variant['id'] ??
                    variant['variantId'] ??
                    '')
                .toString()
                .trim(),
            unit: (variant['unit'] ?? variant['packSize'] ?? '1 unit')
                .toString(),
            price: _toDouble(
              variant['finalPrice'] ?? variant['salePrice'] ?? variant['price'],
            ),
            comparePrice: _toDouble(
              variant['comparePrice'] ??
                  variant['regularPrice'] ??
                  variant['mrp'],
            ),
          ),
        )
        .where((variant) => variant.id.isNotEmpty)
        .toList();

    final selectedVariantMap =
        (defaultVariantId != null && defaultVariantId.isNotEmpty)
        ? variantMaps.firstWhere(
            (variant) {
              final vid = (variant['_id'] ??
                      variant['id'] ??
                      variant['variantId'] ??
                      '')
                  .toString()
                  .trim();
              return vid == defaultVariantId;
            },
            orElse: () => firstVariant,
          )
        : firstVariant;
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
    
    // Try to extract primary image from various sources
    var primaryImage = imageList.isNotEmpty
        ? imageList.first
        : '';
    
    // If no images array, try alternative image fields
    if (primaryImage.isEmpty && thumbnail.isNotEmpty) {
      primaryImage = thumbnail;
    }
    
    // Try additional image sources if still empty
    if (primaryImage.isEmpty) {
      final alternativeImages = [
        'image',
        'imageUrl',
        'productImage',
        'icon',
        'photo',
        'picture',
      ];
      for (final key in alternativeImages) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          primaryImage = value.trim();
          break;
        }
      }
    }
    
    // Fall back to default image only if truly no image found
    if (primaryImage.isEmpty) {
      primaryImage = 'assets/demo/product_1.png';
    }

    final variantPrice = _toDouble(
      selectedVariantMap['finalPrice'] ??
          selectedVariantMap['salePrice'] ??
          selectedVariantMap['price'],
    );
    final productPrice = _toDouble(json['finalPrice'] ?? json['price']);
    final finalPrice = variantPrice ?? productPrice ?? 0;

    final variantComparePrice = _toDouble(
      selectedVariantMap['comparePrice'] ??
          selectedVariantMap['regularPrice'] ??
          selectedVariantMap['mrp'],
    );
    final comparePrice =
        variantComparePrice ??
        _toDouble(json['comparePrice'] ?? json['regularPrice'] ?? json['mrp']);
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

    final slugText =
        (json['slug'] ?? json['productSlug'] ?? json['product_slug'] ?? '')
            .toString()
            .trim();

    return ProductModel(
      id: id,
      slug: slugText.isEmpty ? null : slugText,
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
      moq: variantMaps.isNotEmpty
          ? (selectedVariantMap['unit'] ??
                    selectedVariantMap['packSize'] ??
                    '1 unit')
                .toString()
          : '1 unit',
      rating: (ratingValue is num) ? ratingValue.toDouble() : 4.9,
      imagePath: primaryImage,
      imageUrls: imageList,
      variants: parsedVariants,
      hasOffer:
          (discountValue is num ? discountValue > 0 : false) ||
          (comparePrice != null && comparePrice > finalPrice + 0.0001),
      offerLabel: (discountValue is num && discountValue > 0)
          ? '${discountValue.toInt()}% OFF'
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
      'variants': variants
          .map(
            (variant) => {
              'id': variant.id,
              'unit': variant.unit,
              'price': variant.price,
              'comparePrice': variant.comparePrice,
            },
          )
          .toList(),
      'hasOffer': hasOffer,
      'offerLabel': offerLabel,
    };
  }
}
