import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cart/controllers/cart_controller.dart';

class CheckoutController extends GetxController {
  late final CartController cartController;

  final shippingAddress = ''.obs;
  final selectedAddressIndex = 0.obs;
  final isPlacingOrder = false.obs;
  final savedAddresses = <CheckoutAddress>[
    const CheckoutAddress(
      label: 'Default Address',
      title: 'Pharmacy - Main Branch',
      details: 'House 12, Road 4, Dhanmondi, Dhaka 1205',
    ),
    const CheckoutAddress(
      label: 'Warehouse',
      title: 'Care Life Touch Storage',
      details: 'Plot 7, Sector 3, Uttara, Dhaka 1230',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<CartController>()) {
      cartController = Get.find<CartController>();
    } else {
      cartController = Get.put(CartController());
    }

    if (savedAddresses.isNotEmpty) {
      shippingAddress.value = savedAddresses.first.fullAddress;
    }
  }

  int get totalProductCount => cartController.itemCount;
  double get totalPrice => cartController.subtotal;
  double get discount => 0;
  double get deliveryFee => cartController.deliveryFee;
  double get totalPayable => totalPrice - discount + deliveryFee;

  void syncSelectedAddressFromCurrent() {
    final currentIndex = savedAddresses.indexWhere(
      (address) => address.fullAddress == shippingAddress.value,
    );

    if (currentIndex >= 0) {
      selectedAddressIndex.value = currentIndex;
      return;
    }

    if (savedAddresses.isNotEmpty) {
      selectedAddressIndex.value = 0;
    }
  }

  void selectAddress(int index) {
    selectedAddressIndex.value = index;
  }

  void confirmSelectedAddress() {
    if (savedAddresses.isEmpty) {
      return;
    }

    shippingAddress.value = savedAddresses[selectedAddressIndex.value].fullAddress;
    Get.back();
  }

  Future<void> placeOrder() async {
    if (cartController.cartItems.isEmpty) {
      return;
    }

    if (shippingAddress.value.isEmpty) {
      Get.snackbar(
        'Address Required',
        'Please add a shipping address first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isPlacingOrder.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      cartController.clearCart();

      Get.snackbar(
        'Order Confirmed',
        'Your order has been placed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } finally {
      isPlacingOrder.value = false;
    }
  }
}

class CheckoutAddress {
  final String label;
  final String title;
  final String details;

  const CheckoutAddress({
    required this.label,
    required this.title,
    required this.details,
  });

  String get fullAddress => '$title, $details';
}

