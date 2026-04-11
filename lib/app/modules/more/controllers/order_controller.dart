import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/review_repository.dart';

enum OrderTab { current, completed, canceled }

class OrderController extends GetxController {
  OrderController({
    OrderRepository? orderRepository,
    ReviewRepository? reviewRepository,
  }) : _orderRepository = orderRepository ?? Get.find<OrderRepository>(),
       _reviewRepository = reviewRepository ?? Get.find<ReviewRepository>();

  final OrderRepository _orderRepository;
  final ReviewRepository _reviewRepository;

  final orders = <Map<String, dynamic>>[].obs;
  final selectedOrder = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = ''.obs;
  final activeTab = OrderTab.current.obs;
  final reviewEligibilityReady = false.obs;
  final reviewableProductKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyOrders();
  }

  List<Map<String, dynamic>> get currentOrders =>
      orders.where(_isCurrentOrder).toList(growable: false);

  List<Map<String, dynamic>> get completedOrders =>
      orders.where(_isCompletedOrder).toList(growable: false);

  List<Map<String, dynamic>> get canceledOrders =>
      orders.where(_isCanceledOrder).toList(growable: false);

  List<Map<String, dynamic>> get activeTabOrders {
    switch (activeTab.value) {
      case OrderTab.current:
        return currentOrders;
      case OrderTab.completed:
        return completedOrders;
      case OrderTab.canceled:
        return canceledOrders;
    }
  }

  void setActiveTab(OrderTab tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
  }

  Future<void> loadMyOrders({int? page, int? limit}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _orderRepository.getMyOrders(page: page, limit: limit);
      orders.assignAll(data);
      await _loadReviewableProducts();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load orders', error, stackTrace);
      errorMessage.value = _resolveError(error);
      orders.clear();
      reviewEligibilityReady.value = false;
      reviewableProductKeys.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _orderRepository.getSingleOrder(orderId);
      selectedOrder.value = data;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load order details', error, stackTrace);
      errorMessage.value = _resolveError(error);
      selectedOrder.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelOrder({required String orderId, required String reason}) async {
    if (reason.trim().isEmpty) {
      errorMessage.value = 'Cancellation reason is required.';
      return false;
    }

    try {
      isMutating.value = true;
      errorMessage.value = '';
      await _orderRepository.cancelOrder(orderId: orderId, reason: reason);
      await loadOrderDetails(orderId);
      await loadMyOrders();
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to cancel order', error, stackTrace);
      errorMessage.value = _resolveError(error);
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> returnOrder({
    required String orderId,
    required String reason,
    List<String>? images,
  }) async {
    if (reason.trim().isEmpty) {
      errorMessage.value = 'Return reason is required.';
      return false;
    }

    try {
      isMutating.value = true;
      errorMessage.value = '';
      await _orderRepository.returnOrder(
        orderId: orderId,
        reason: reason,
        images: images,
      );
      await loadOrderDetails(orderId);
      await loadMyOrders();
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to return order', error, stackTrace);
      errorMessage.value = _resolveError(error);
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  String orderIdOf(Map<String, dynamic> order) {
    return (order['_id'] ?? order['id'] ?? order['orderId'] ?? '').toString();
  }

  String orderNumberOf(Map<String, dynamic> order) {
    return (order['orderNo'] ?? order['orderNumber'] ?? order['invoiceNo'] ?? orderIdOf(order))
        .toString();
  }

  String orderStatusOf(Map<String, dynamic> order) {
    return (order['status'] ?? order['orderStatus'] ?? 'pending').toString();
  }

  String orderStatusLabelOf(Map<String, dynamic> order) {
    final status = _normalizedStatus(order);
    if (status.isEmpty) return 'Pending';
    return status
        .split('-')
        .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  double orderTotalOf(Map<String, dynamic> order) {
    final raw = order['total'] ?? order['grandTotal'] ?? order['totalAmount'] ?? 0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 0;
  }

  int orderItemCountOf(Map<String, dynamic> order) {
    final items = order['items'];
    if (items is! List) return 0;
    return items.fold<int>(0, (sum, item) {
      if (item is! Map) return sum + 1;
      final rawQty = item['quantity'];
      if (rawQty is num) return sum + rawQty.toInt();
      return sum + (int.tryParse(rawQty?.toString() ?? '') ?? 1);
    });
  }

  String orderAmountTextOf(Map<String, dynamic> order) {
    return '৳${orderTotalOf(order).toStringAsFixed(0)}';
  }

  String estimatedDeliveryOf(Map<String, dynamic> order) {
    final tracking = _toMap(order['tracking']);
    final estimated = tracking?['estimatedDelivery']?.toString();
    if (estimated != null && estimated.trim().isNotEmpty) {
      return _formatDateTime(estimated) ?? '--';
    }

    final createdAt = order['createdAt']?.toString();
    final days = _toMap(order['estimatedDays']);
    final minDays = _asInt(days?['min']);
    if (createdAt != null && minDays != null) {
      final dt = DateTime.tryParse(createdAt)?.toLocal();
      if (dt != null) {
        final target = dt.add(Duration(days: minDays));
        return _formatLocalDateTime(target);
      }
    }

    return '--';
  }

  bool canCancelOrder(Map<String, dynamic> order) {
    final status = _normalizedStatus(order);
    return status == 'pending' || status == 'confirmed' || status == 'processing';
  }

  bool canTrackOrder(Map<String, dynamic> order) {
    final status = _normalizedStatus(order);
    return status == 'confirmed' || status == 'processing' || status == 'shipped';
  }

  bool canReturnOrder(Map<String, dynamic> order) {
    return _normalizedStatus(order) == 'delivered';
  }

  bool canReviewOrder(Map<String, dynamic> order) {
    if (!_isCompletedOrder(order)) return false;

    final item = firstItemOf(order);
    if (item.isEmpty || _isItemAlreadyReviewed(item)) {
      return false;
    }

    final productId = firstProductIdOf(order);
    final orderId = orderIdOf(order);
    final variantId = firstVariantIdOf(order);
    if (productId.isEmpty || orderId.isEmpty) return false;

    if (!reviewEligibilityReady.value) {
      // Keep UX unblocked if eligibility list is not available yet.
      return true;
    }

    return reviewableProductKeys.contains(_reviewKey(productId, orderId, variantId)) ||
        reviewableProductKeys.contains(_reviewKey(productId, orderId, '')) ||
        reviewableProductKeys.contains(_reviewKey(productId, '', ''));
  }

  String firstProductIdOf(Map<String, dynamic> order) {
    final items = order['items'];
    if (items is! List || items.isEmpty) return '';

    final first = items.first;
    if (first is! Map) return '';

    final product = first['product'];
    if (product is String) return product;
    if (product is Map) {
      final value = product['_id'] ?? product['id'];
      return (value ?? '').toString();
    }

    return (first['productId'] ?? '').toString();
  }

  String firstVariantIdOf(Map<String, dynamic> order) {
    final item = firstItemOf(order);
    if (item.isEmpty) return '';

    final direct = item['variantId'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString();
    }

    final variant = item['variant'];
    if (variant is Map) {
      final id = variant['variantId'] ?? variant['_id'] ?? variant['id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString();
      }
    }
    return '';
  }

  Map<String, dynamic> firstItemOf(Map<String, dynamic> order) {
    final items = order['items'];
    if (items is! List || items.isEmpty) return const {};

    final first = items.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) {
      return first.map((k, v) => MapEntry(k.toString(), v));
    }
    return const {};
  }

  bool canReorder(Map<String, dynamic> order) {
    return _isCanceledOrder(order);
  }

  bool _isCurrentOrder(Map<String, dynamic> order) {
    const current = {
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'return-requested',
      'return-approved',
    };
    return current.contains(_normalizedStatus(order));
  }

  bool _isCompletedOrder(Map<String, dynamic> order) {
    return _normalizedStatus(order) == 'delivered';
  }

  bool _isCanceledOrder(Map<String, dynamic> order) {
    return _normalizedStatus(order) == 'cancelled';
  }

  String _normalizedStatus(Map<String, dynamic> order) {
    return orderStatusOf(order).trim().toLowerCase();
  }

  String? _formatDateTime(String input) {
    final dt = DateTime.tryParse(input)?.toLocal();
    if (dt == null) return null;
    return _formatLocalDateTime(dt);
  }

  String _formatLocalDateTime(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour24 = dateTime.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final meridiem = hour24 >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $meridiem, ${dateTime.day} ${months[dateTime.month - 1]}';
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  String _resolveError(dynamic error) {
    final message = error.toString();
    if (message.trim().isEmpty) {
      return 'Something went wrong. Please try again.';
    }
    return message;
  }

  Future<void> _loadReviewableProducts() async {
    try {
      final raw = await _reviewRepository.getReviewableProducts();
      final keys = <String>{};

      for (final item in raw) {
        final productId = _firstNonEmptyString([
          item['productId'],
          item['product'],
          _toMap(item['product'])?['_id'],
          _toMap(item['product'])?['id'],
        ]);
        if (productId == null) continue;

        final orderId = _firstNonEmptyString([
          item['orderId'],
          item['order'],
          _toMap(item['order'])?['_id'],
          _toMap(item['order'])?['id'],
        ]);
        final variantId = _firstNonEmptyString([
          item['variantId'],
          item['variant'],
          _toMap(item['variant'])?['_id'],
          _toMap(item['variant'])?['id'],
        ]);

        keys.add(_reviewKey(productId, orderId ?? '', variantId ?? ''));
        if (orderId != null) {
          keys.add(_reviewKey(productId, orderId, ''));
        }
        keys.add(_reviewKey(productId, '', ''));
      }

      reviewableProductKeys
        ..clear()
        ..addAll(keys);
      reviewEligibilityReady.value = true;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load reviewable products', error, stackTrace);
      reviewEligibilityReady.value = false;
      reviewableProductKeys.clear();
    }
  }

  bool _isItemAlreadyReviewed(Map<String, dynamic> item) {
    final reviewedFlag = item['isReviewed'] ?? item['reviewed'];
    if (reviewedFlag is bool && reviewedFlag) return true;

    final reviewId = _firstNonEmptyString([
      item['reviewId'],
      item['review'],
      _toMap(item['review'])?['_id'],
      _toMap(item['review'])?['id'],
    ]);
    return reviewId != null;
  }

  String _reviewKey(String productId, String orderId, String variantId) {
    return '${productId.trim()}|${orderId.trim()}|${variantId.trim()}';
  }

  String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }
}

