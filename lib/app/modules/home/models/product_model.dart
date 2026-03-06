/// Product Model
class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double? maxPrice;
  final String moq;
  final double rating;
  final String imagePath;
  final bool hasOffer;
  final String? offerLabel;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.maxPrice,
    required this.moq,
    this.rating = 4.9,
    required this.imagePath,
    this.hasOffer = false,
    this.offerLabel,
  });

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
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      maxPrice: json['maxPrice'] != null ? (json['maxPrice']).toDouble() : null,
      moq: json['moq'] ?? '',
      rating: (json['rating'] ?? 4.9).toDouble(),
      imagePath: json['imagePath'] ?? '',
      hasOffer: json['hasOffer'] ?? false,
      offerLabel: json['offerLabel'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'maxPrice': maxPrice,
      'moq': moq,
      'rating': rating,
      'imagePath': imagePath,
      'hasOffer': hasOffer,
      'offerLabel': offerLabel,
    };
  }
}

