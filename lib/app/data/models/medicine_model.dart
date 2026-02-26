import 'package:flutter/material.dart';

/// Base model class that all models should extend
abstract class BaseModel {
  /// Convert model to JSON
  Map<String, dynamic> toJson();

  /// Create model from JSON
  /// This should be implemented by child classes
}

/// Example Medicine Model
class Medicine extends BaseModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isPrescriptionRequired;
  final int stockQuantity;
  final String manufacturer;
  final DateTime? expiryDate;
  final List<String>? tags;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isPrescriptionRequired = false,
    this.stockQuantity = 0,
    required this.manufacturer,
    this.expiryDate,
    this.tags,
  });

  /// Create Medicine from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      isPrescriptionRequired: json['isPrescriptionRequired'] ?? json['is_prescription_required'] ?? false,
      stockQuantity: json['stockQuantity'] ?? json['stock_quantity'] ?? 0,
      manufacturer: json['manufacturer'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'])
          : (json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date']) : null),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isPrescriptionRequired': isPrescriptionRequired,
      'stockQuantity': stockQuantity,
      'manufacturer': manufacturer,
      'expiryDate': expiryDate?.toIso8601String(),
      'tags': tags,
    };
  }

  /// Check if medicine is in stock
  bool get isInStock => stockQuantity > 0;

  /// Check if medicine is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Copy with method for immutability
  Medicine copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isPrescriptionRequired,
    int? stockQuantity,
    String? manufacturer,
    DateTime? expiryDate,
    List<String>? tags,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrescriptionRequired: isPrescriptionRequired ?? this.isPrescriptionRequired,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      manufacturer: manufacturer ?? this.manufacturer,
      expiryDate: expiryDate ?? this.expiryDate,
      tags: tags ?? this.tags,
    );
  }
}

