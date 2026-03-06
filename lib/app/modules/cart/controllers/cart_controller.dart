import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../home/models/product_model.dart';

/// Cart Controller - Manages shopping cart state and operations
class CartController extends GetxController {
  // Observable cart items
  final cartItems = <CartItem>[].obs;

  // Computed values
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => cartItems.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double get deliveryFee => subtotal > 500 ? 0.0 : 50.0;

  double get total => subtotal + deliveryFee;

  /// Add product to cart
  void addToCart(ProductModel product) {
    try {
      final existingIndex = cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex != -1) {
        // Update quantity
        cartItems[existingIndex].quantity++;
        cartItems.refresh();
      } else {
        // Add new item
        cartItems.add(CartItem(product: product, quantity: 1));
      }

      AppLogger.success('Added ${product.name} to cart');

      Get.snackbar(
        'Added to Cart',
        '${product.name} has been added to your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add to cart', e, stackTrace);
    }
  }

  /// Remove product from cart
  void removeFromCart(String productId) {
    try {
      cartItems.removeWhere((item) => item.product.id == productId);
      AppLogger.info('Removed product from cart');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to remove from cart', e, stackTrace);
    }
  }

  /// Update quantity
  void updateQuantity(String productId, int quantity) {
    try {
      if (quantity <= 0) {
        removeFromCart(productId);
        return;
      }

      final index = cartItems.indexWhere(
        (item) => item.product.id == productId,
      );

      if (index != -1) {
        cartItems[index].quantity = quantity;
        cartItems.refresh();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update quantity', e, stackTrace);
    }
  }

  /// Increase quantity
  void increaseQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
    }
  }

  /// Decrease quantity
  void decreaseQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
      } else {
        removeFromCart(productId);
      }
    }
  }

  /// Clear cart
  void clearCart() {
    cartItems.clear();
    AppLogger.info('Cart cleared');
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }

  /// Get product quantity in cart
  int getQuantity(String productId) {
    final item = cartItems.firstWhereOrNull(
      (item) => item.product.id == productId,
    );
    return item?.quantity ?? 0;
  }
}

/// Cart Item Model
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
