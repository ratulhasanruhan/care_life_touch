import '../../modules/home/models/product_model.dart';

class CartApiItem {
  final String itemId;
  final String productId;
  final String? variantId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final ProductModel product;

  const CartApiItem({
    required this.itemId,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.product,
  });

  factory CartApiItem.fromJson(Map<String, dynamic> json) {
    final productMap = _mapValue(json['product']) ??
        _mapValue(json['productId']) ??
        _mapValue(json['item']) ??
        json;
    final variantMap = _mapValue(json['variant']) ?? _mapValue(json['selectedVariant']);

    final product = ProductModel.fromJson(productMap);
    final quantity = _asInt(json['quantity']) ?? 1;
    final productId = (json['productId'] is String || json['productId'] is num)
        ? json['productId'].toString()
        : (product.id.isNotEmpty ? product.id : (productMap['_id'] ?? productMap['id'] ?? '').toString());
    final variantId = (json['variantId'] ?? variantMap?['_id'] ?? variantMap?['id'] ?? product.defaultVariantId)
        ?.toString();

    final unitPrice = _asDouble(
          json['unitPrice'] ??
              json['price'] ??
              json['finalPrice'] ??
              variantMap?['finalPrice'] ??
              variantMap?['price'] ??
              product.price,
        ) ??
        product.price;

    final totalPrice = _asDouble(json['totalPrice'] ?? json['subtotal']) ??
        (unitPrice * quantity);

    return CartApiItem(
      itemId: (json['_id'] ?? json['id'] ?? json['itemId'] ?? productId).toString(),
      productId: productId,
      variantId: variantId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      product: product,
    );
  }

  CartApiItem copyWith({
    String? itemId,
    String? productId,
    String? variantId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    ProductModel? product,
  }) {
    return CartApiItem(
      itemId: itemId ?? this.itemId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      product: product ?? this.product,
    );
  }
}

class CartApiSnapshot {
  final List<CartApiItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;

  const CartApiSnapshot({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
  });

  factory CartApiSnapshot.fromJson(Map<String, dynamic> json) {
    final cartMap = _mapValue(json['cart']) ?? _mapValue(json['data']) ?? json;
    final itemsRaw = cartMap['items'] ?? cartMap['cartItems'] ?? cartMap['products'] ?? json['items'];

    final items = <CartApiItem>[];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        final itemMap = _mapValue(item);
        if (itemMap != null) {
          items.add(CartApiItem.fromJson(itemMap));
        }
      }
    }

    final computedSubtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final subtotal = _asDouble(
          cartMap['subtotal'] ?? cartMap['subTotal'] ?? cartMap['totalPrice'] ?? json['subtotal'],
        ) ??
        computedSubtotal;
    final discount = _asDouble(cartMap['discount'] ?? json['discount']) ?? 0;
    final deliveryFee = _asDouble(cartMap['deliveryFee'] ?? cartMap['shippingFee'] ?? json['deliveryFee']) ?? 0;
    final total = _asDouble(
          cartMap['total'] ?? cartMap['totalPayable'] ?? cartMap['grandTotal'] ?? json['total'],
        ) ??
        (subtotal - discount + deliveryFee);

    return CartApiSnapshot(
      items: items,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
    );
  }
}

Map<String, dynamic>? _mapValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

double? _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

