import 'package:get/get.dart';

import '../models/api_exception.dart';
import '../models/cart_api_model.dart';
import '../providers/api_provider.dart';

class CartRepository {
  CartRepository({ApiProvider? apiProvider})
      : _api = apiProvider ??
            (Get.isRegistered<ApiProvider>()
                ? Get.find<ApiProvider>()
                : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<CartApiSnapshot> getCart() async {
    final response = await _api.getData('/cart');
    return _snapshotFromResponse(response);
  }

  Future<CartApiSnapshot> addToCart({
    required String productId,
    required String variantId,
    required int quantity,
  }) async {
    final response = await _api.postData(
      '/cart-add',
      body: {
        'productId': productId,
        'variantId': variantId,
        'quantity': quantity,
      },
    );
    return _snapshotFromResponse(response);
  }

  Future<CartApiSnapshot> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    final response = await _api.putData(
      '/cart-update',
      body: {
        'itemId': itemId,
        'quantity': quantity,
      },
    );
    return _snapshotFromResponse(response);
  }

  Future<CartApiSnapshot> removeCartItem(String itemId) async {
    final response = await _api.deleteData('/cart-remove/$itemId');
    return _snapshotFromResponse(response);
  }

  Future<void> clearCart() async {
    await _api.deleteData('/cart-clear');
  }

  CartApiSnapshot _snapshotFromResponse(dynamic response) {
    final map = _toMap(response);
    if (map == null) {
      throw ApiException('Unexpected cart response format.', details: response);
    }
    return CartApiSnapshot.fromJson(map);
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}

