import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/models/cart_api_model.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../home/models/product_model.dart';

/// Cart Controller - Manages shopping cart state and operations
class CartController extends GetxController {
  CartController({
    CartRepository? cartRepository,
    StorageService? storageService,
  }) : _cartRepository = cartRepository ?? Get.find<CartRepository>(),
       _storage = storageService ?? Get.find<StorageService>();

  final CartRepository _cartRepository;
  final StorageService _storage;

  final cartItems = <CartItem>[].obs;
  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = ''.obs;

  final Map<String, ProductModel> _knownProducts = <String, ProductModel>{};

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
      _applySnapshot(
        const CartApiSnapshot(
          items: [],
          subtotal: 0,
          discount: 0,
          deliveryFee: 0,
          total: 0,
        ),
      );
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
      errorMessage.value = _resolveMessage(
        error,
        'Failed to load cart. Please try again.',
      );
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
    String? variantId,
  }) async {
    final resolvedVariantId = (variantId ?? product.defaultVariantId ?? '')
        .trim();
    if (resolvedVariantId.isEmpty) {
      _showError('This product is not available for cart yet.');
      return;
    }

    _knownProducts[product.id] = product;

    await _mutateCart(
      () => _cartRepository.addToCart(
        productId: product.id,
        variantId: resolvedVariantId,
        quantity: quantity,
      ),
    );
  }

  Future<void> removeFromCart(String productId) async {
    final item = _findByProductId(productId);
    if (item == null || item.itemId.isEmpty) {
      return;
    }

    await _mutateCart(
      () => _cartRepository.removeCartItem(item.itemId),
      successMessage: 'Item removed from cart',
    );
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final item = _findByProductId(productId);
    if (item == null) {
      return;
    }

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    await _mutateCart(
      () => _cartRepository.updateCartItem(
        itemId: item.itemId,
        quantity: quantity,
      ),
    );
  }

  Future<void> increaseQuantity(String productId) async {
    final item = _findByProductId(productId);
    if (item != null) {
      await updateQuantity(productId, item.quantity + 1);
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    final item = _findByProductId(productId);
    if (item != null) {
      await updateQuantity(productId, item.quantity - 1);
    }
  }

  Future<void> clearCart({bool notify = false}) async {
    try {
      isMutating.value = true;
      await _cartRepository.clearCart();
      _applySnapshot(
        const CartApiSnapshot(
          items: [],
          subtotal: 0,
          discount: 0,
          deliveryFee: 0,
          total: 0,
        ),
      );
      if (notify) {
        Get.snackbar(
          'Success',
          'Cart cleared successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to clear cart', error, stackTrace);
      _showError(
        _resolveMessage(error, 'Failed to clear cart. Please try again.'),
      );
    } finally {
      isMutating.value = false;
    }
  }

  bool isInCart(String productId) => _findByProductId(productId) != null;

  int getQuantity(String productId) =>
      _findByProductId(productId)?.quantity ?? 0;

  CartItem? _findByProductId(String productId) {
    return cartItems.firstWhereOrNull(
      (item) => item.product.id == productId || item.productId == productId,
    );
  }

  // List<Map<String, dynamic>> toOrderItems() {
  //   return cartItems
  //       .where((item) => item.variantId != null && item.variantId!.isNotEmpty)
  //       .map(
  //         (item) => {
  //           'productId': item.product.id.isNotEmpty ? item.product.id : item.productId,
  //           'variantId': item.variantId,
  //           'quantity': item.quantity,
  //         },
  //       )
  //       .toList();
  // }

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
        Get.snackbar(
          'Success',
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('Cart mutation failed', error, stackTrace);
      _showError(
        _resolveMessage(error, 'Unable to update cart. Please try again.'),
      );
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
              productId: item.productId,
              variantId: item.variantId,
              product: _mergeKnownProduct(item),
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

  ProductModel _mergeKnownProduct(CartApiItem item) {
    final cached = _knownProducts[item.productId];
    final current = item.product;

    if (cached == null) {
      if (current.name.trim().isNotEmpty &&
          current.name.trim().toLowerCase() != 'product') {
        _knownProducts[item.productId] = current;
      }
      return current;
    }

    final merged = ProductModel(
      id: current.id.isNotEmpty ? current.id : cached.id,
      slug: current.slug ?? cached.slug,
      defaultVariantId: current.defaultVariantId ?? cached.defaultVariantId,
      name:
          current.name.trim().isNotEmpty &&
              current.name.trim().toLowerCase() != 'product'
          ? current.name
          : cached.name,
      brandId: (current.brandId != null && current.brandId!.trim().isNotEmpty)
          ? current.brandId
          : cached.brandId,
      brand: _isMeaningfulBrand(current.brand) ? current.brand : cached.brand,
      categoryName: current.categoryName.trim().isNotEmpty
          ? current.categoryName
          : cached.categoryName,
      description: current.description ?? cached.description,
      price: current.price > 0 ? current.price : cached.price,
      maxPrice: current.maxPrice ?? cached.maxPrice,
      moq: current.moq.trim().isNotEmpty ? current.moq : cached.moq,
      rating: current.rating > 0 ? current.rating : cached.rating,
      imagePath: current.imagePath.trim().isNotEmpty
          ? current.imagePath
          : cached.imagePath,
      imageUrls: current.imageUrls.isNotEmpty
          ? current.imageUrls
          : cached.imageUrls,
      variants: current.variants.isNotEmpty
          ? current.variants
          : cached.variants,
      hasOffer: current.hasOffer || cached.hasOffer,
      offerLabel: current.offerLabel ?? cached.offerLabel,
    );

    _knownProducts[item.productId] = merged;
    return merged;
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

  bool _isMeaningfulBrand(String value) {
    final text = value.trim();
    if (text.isEmpty || text.toLowerCase() == 'unknown brand') {
      return false;
    }
    return !RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(text);
  }

  /// Convert cart items to order format
  List<Map<String, dynamic>> toOrderItems() {
    return cartItems
        .where((item) => (item.variantId ?? '').trim().isNotEmpty)
        .map(
          (item) => <String, dynamic>{
            'productId': item.productId,
            'variantId': (item.variantId ?? '').trim(),
            'quantity': item.quantity,
          },
        )
        .toList();
  }
}

/// Cart Item Model
class CartItem {
  final String itemId;
  final String productId;
  final String? variantId;
  final ProductModel product;
  int quantity;
  final double unitPrice;
  final double totalPrice;

  CartItem({
    required this.itemId,
    required this.productId,
    required this.variantId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
