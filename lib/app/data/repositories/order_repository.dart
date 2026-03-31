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

  Future<List<Map<String, dynamic>>> getMyOrders({
    int? page,
    int? limit,
  }) async {
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
    final response = await _api.getData(
      '/get-my-orders',
      query: query.isEmpty ? null : query,
    );
    final map = _toMap(response);
    if (map == null) {
      return const [];
    }

    final data = _toMap(map['data']) ?? map;
    final orders = data['orders'] ?? map['orders'] ?? data['items'] ?? map['items'];
    if (orders is! List) {
      return const [];
    }

    return orders.map(_toMap).whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getSingleOrder(String orderId) async {
    final response = await _api.getData('/get-my-order/$orderId');
    final map = _toMap(response);
    if (map == null) {
      throw ApiException('Unexpected order response format.', details: response);
    }

    final data = _toMap(map['data']) ?? map;
    final order = _toMap(data['order']) ?? _toMap(map['order']) ?? data;
    return order;
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    final response = await _api.putData(
      '/cancel-order/$orderId',
      body: {
        'reason': reason.trim(),
      },
    );
    final map = _toMap(response);
    if (map == null) {
      throw ApiException('Unexpected cancel response format.', details: response);
    }
    return map;
  }

  Future<Map<String, dynamic>> returnOrder({
    required String orderId,
    required String reason,
    List<String>? images,
  }) async {
    final response = await _api.putData(
      '/return-order/$orderId',
      body: {
        'reason': reason.trim(),
        if (images != null && images.isNotEmpty)
          'images': images.map((url) => {'url': url}).toList(growable: false),
      },
    );
    final map = _toMap(response);
    if (map == null) {
      throw ApiException('Unexpected return response format.', details: response);
    }
    return map;
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

