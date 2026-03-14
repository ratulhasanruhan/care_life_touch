import 'package:get/get.dart';

import '../models/api_exception.dart';
import '../providers/api_provider.dart';

class OrderRepository {
  OrderRepository({ApiProvider? apiProvider})
      : _api = apiProvider ??
            (Get.isRegistered<ApiProvider>()
                ? Get.find<ApiProvider>()
                : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
    String deliveryShift = 'morning',
    String paymentMethod = 'cod',
    String? couponCode,
  }) async {
    final response = await _api.postData(
      '/create-order',
      body: {
        'items': items,
        'addressId': addressId,
        'deliveryShift': deliveryShift,
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'couponCode': couponCode.trim(),
      },
    );

    final map = _toMap(response);
    if (map == null) {
      throw ApiException('Unexpected order response format.', details: response);
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final response = await _api.getData('/get-my-orders');
    final map = _toMap(response);
    if (map == null) {
      return const [];
    }

    final data = _toMap(map['data']) ?? map;
    final orders = data['orders'] ?? data['items'] ?? map['orders'];
    if (orders is! List) {
      return const [];
    }

    return orders
        .map(_toMap)
        .whereType<Map<String, dynamic>>()
        .toList();
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

