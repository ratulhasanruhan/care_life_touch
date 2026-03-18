import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  OrderController({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? Get.find<OrderRepository>();

  final OrderRepository _orderRepository;

  final orders = <Map<String, dynamic>>[].obs;
  final selectedOrder = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyOrders();
  }

  Future<void> loadMyOrders({int? page, int? limit}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _orderRepository.getMyOrders(page: page, limit: limit);
      orders.assignAll(data);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load orders', error, stackTrace);
      errorMessage.value = _resolveError(error);
      orders.clear();
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
    return (order['orderNumber'] ?? order['invoiceNo'] ?? orderIdOf(order)).toString();
  }

  String orderStatusOf(Map<String, dynamic> order) {
    return (order['status'] ?? order['orderStatus'] ?? 'pending').toString();
  }

  double orderTotalOf(Map<String, dynamic> order) {
    final raw = order['total'] ?? order['grandTotal'] ?? order['totalAmount'] ?? 0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 0;
  }

  String _resolveError(dynamic error) {
    final message = error.toString();
    if (message.trim().isEmpty) {
      return 'Something went wrong. Please try again.';
    }
    return message;
  }
}

