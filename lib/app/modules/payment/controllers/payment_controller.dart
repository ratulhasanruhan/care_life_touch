import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../routes/app_pages.dart';
import '../../cart/controllers/cart_controller.dart';

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.key,
    required this.label,
    required this.iconAsset,
    this.isRecommended = false,
  });

  final String key;
  final String label;
  final String iconAsset;
  final bool isRecommended;
}

class PaymentController extends GetxController {
  PaymentController({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? Get.find<OrderRepository>();

  final OrderRepository _orderRepository;
  late final CartController cartController;

  final isProcessing = false.obs;
  final selectedMethodKey = 'cod'.obs;
  final selectedDeliveryShift = 'morning'.obs;

  static const String codMethodKey = 'cod';

  late final String addressId;
  late final String shippingAddress;

  final methods = const <PaymentMethodOption>[
    PaymentMethodOption(
      key: codMethodKey,
      label: 'Cash on Delivery (COD)',
      iconAsset: 'assets/images/card.png',
      isRecommended: true,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    cartController = Get.find<CartController>();

    final args = Get.arguments;
    if (args is Map) {
      addressId = (args['addressId'] ?? '').toString();
      shippingAddress = (args['shippingAddress'] ?? '').toString();
    } else {
      addressId = '';
      shippingAddress = '';
    }
  }

  double get subtotal => cartController.subtotal;
  double get total => cartController.total;

  void selectMethod(String key) {
    // Payment is fixed to COD.
    selectedMethodKey.value = codMethodKey;
  }

  void selectDeliveryShift(String shift) {
    selectedDeliveryShift.value = shift;
  }

  Future<void> completePayment() async {
    if (isProcessing.value) return;

    if (addressId.isEmpty) {
      Get.snackbar(
        'Address Missing',
        'Please go back and select a shipping address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final orderItems = cartController.toOrderItems();
    if (orderItems.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Your cart items are missing required information.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isProcessing.value = true;

      await _orderRepository.createOrder(
        items: orderItems,
        addressId: addressId,
        deliveryShift: selectedDeliveryShift.value,
        paymentMethod: codMethodKey,
      );

      await cartController.clearCart();
      _showPaymentSuccessSheet();
    } catch (error, stackTrace) {
      AppLogger.error('Payment failed', error, stackTrace);
      Get.snackbar(
        'Payment Failed',
        _resolveMessage(error, 'Unable to process payment right now. Please try again.'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  String _resolveMessage(Object error, String fallback) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }

  void _showPaymentSuccessSheet() {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 358,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 54,
                    color: Color(0xFF064E36),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thank you for your order!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF01060F),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your payment has been successfully processed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0x99191930),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed(Routes.HOME);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

