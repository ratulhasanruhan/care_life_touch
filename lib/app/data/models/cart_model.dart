import 'medicine_model.dart';

/// Cart Item Model
class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({
    required this.medicine,
    this.quantity = 1,
  });

  /// Calculate total price for this item
  double get totalPrice => medicine.price * quantity;

  /// Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      medicine: Medicine.fromJson(json['medicine']),
      quantity: json['quantity'] ?? 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'medicine': medicine.toJson(),
      'quantity': quantity,
    };
  }

  /// Copy with method
  CartItem copyWith({
    Medicine? medicine,
    int? quantity,
  }) {
    return CartItem(
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Cart Model
class Cart {
  final List<CartItem> items;

  Cart({this.items = const []});

  /// Get total items count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get total price
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Get total unique items
  int get uniqueItemCount => items.length;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Create Cart from JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: json['items'] != null
          ? (json['items'] as List).map((item) => CartItem.fromJson(item)).toList()
          : [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

