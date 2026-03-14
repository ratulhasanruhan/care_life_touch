import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/models/cart_api_model.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../home/models/product_model.dart';

/// Cart Controller - Manages shopping cart state and operations
class CartController extends GetxController {
  CartController({CartRepository? cartRepository, StorageService? storageService})
      : _cartRepository = cartRepository ?? Get.find<CartRepository>(),
        _storage = storageService ?? Get.find<StorageService>();

  final CartRepository _cartRepository;
  final StorageService _storage;

  final cartItems = <CartItem>[].obs;
  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = ''.obs;

  double _subtotal = 0;
  double _discount = 0;
  double _deliveryFee = 0;
  double _total = 0;

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _subtotal;
  double get discount => _discount;
  double get deliveryFee => _deliveryFee;
  double get total => _total;

  @override
  void onInit() {
    super.onInit();
    if (_storage.isLoggedIn) {
      loadCart();
    }
  }

  Future<void> loadCart({bool showLoader = true}) async {
    if (!_storage.isLoggedIn) {
      _applySnapshot(const CartApiSnapshot(items: [], subtotal: 0, discount: 0, deliveryFee: 0, total: 0));
      return;
    }

    try {
      if (showLoader) {
        isLoading.value = true;
      }
      errorMessage.value = '';
      final snapshot = await _cartRepository.getCart();
      _applySnapshot(snapshot);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load cart', error, stackTrace);
      errorMessage.value = _resolveMessage(error, 'Failed to load cart. Please try again.');
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final variantId = product.defaultVariantId;
    if (variantId == null || variantId.isEmpty) {
      _showError('This product is not available for cart yet.');
      return;
    }

    await _mutateCart(
      () => _cartRepository.addToCart(
        productId: product.id,
        variantId: variantId,
        quantity: quantity,
      ),
      successMessage: '${product.name} added to cart',
    );
  }

  Future<void> removeFromCart(String productId) async {
    final item = cartItems.firstWhereOrNull((entry) => entry.product.id == productId);
    if (item == null || item.itemId.isEmpty) {
      return;
    }

    await _mutateCart(
      () => _cartRepository.removeCartItem(item.itemId),
      successMessage: 'Item removed from cart',
    );
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final item = cartItems.firstWhereOrNull((entry) => entry.product.id == productId);
    if (item == null) {
      return;
    }

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    await _mutateCart(
      () => _cartRepository.updateCartItem(itemId: item.itemId, quantity: quantity),
    );
  }

  Future<void> increaseQuantity(String productId) async {
    final item = cartItems.firstWhereOrNull((entry) => entry.product.id == productId);
    if (item != null) {
      await updateQuantity(productId, item.quantity + 1);
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    final item = cartItems.firstWhereOrNull((entry) => entry.product.id == productId);
    if (item != null) {
      await updateQuantity(productId, item.quantity - 1);
    }
  }

  Future<void> clearCart({bool notify = false}) async {
    try {
      isMutating.value = true;
      await _cartRepository.clearCart();
      _applySnapshot(const CartApiSnapshot(items: [], subtotal: 0, discount: 0, deliveryFee: 0, total: 0));
      if (notify) {
        Get.snackbar('Success', 'Cart cleared successfully', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to clear cart', error, stackTrace);
      _showError(_resolveMessage(error, 'Failed to clear cart. Please try again.'));
    } finally {
      isMutating.value = false;
    }
  }

  bool isInCart(String productId) => cartItems.any((item) => item.product.id == productId);

  int getQuantity(String productId) =>
      cartItems.firstWhereOrNull((item) => item.product.id == productId)?.quantity ?? 0;

  List<Map<String, dynamic>> toOrderItems() {
    return cartItems
        .where((item) => item.variantId != null && item.variantId!.isNotEmpty)
        .map(
          (item) => {
            'productId': item.product.id,
            'variantId': item.variantId,
            'quantity': item.quantity,
          },
        )
        .toList();
  }

  Future<void> _mutateCart(
    Future<CartApiSnapshot> Function() action, {
    String? successMessage,
  }) async {
    try {
      isMutating.value = true;
      errorMessage.value = '';
      final snapshot = await action();
      _applySnapshot(snapshot);
      if (successMessage != null && successMessage.isNotEmpty) {
        Get.snackbar('Success', successMessage, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (error, stackTrace) {
      AppLogger.error('Cart mutation failed', error, stackTrace);
      _showError(_resolveMessage(error, 'Unable to update cart. Please try again.'));
    } finally {
      isMutating.value = false;
    }
  }

  void _applySnapshot(CartApiSnapshot snapshot) {
    cartItems.assignAll(
      snapshot.items
          .map(
            (item) => CartItem(
              itemId: item.itemId,
              variantId: item.variantId,
              product: item.product,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              totalPrice: item.totalPrice,
            ),
          )
          .toList(),
    );
    _subtotal = snapshot.subtotal;
    _discount = snapshot.discount;
    _deliveryFee = snapshot.deliveryFee;
    _total = snapshot.total;
  }

  String _resolveMessage(Object error, String fallback) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }

  void _showError(String message) {
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }
}

/// Cart Item Model
class CartItem {
  final String itemId;
  final String? variantId;
  final ProductModel product;
  int quantity;
  final double unitPrice;
  final double totalPrice;

  CartItem({
    required this.itemId,
    required this.variantId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
