import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/repositories/address_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../routes/app_pages.dart';

class CheckoutController extends GetxController {
  CheckoutController({
    AddressRepository? addressRepository,
  }) : _addressRepository = addressRepository ?? Get.find<AddressRepository>();

  late final CartController cartController;
  final AddressRepository _addressRepository;

  final savedAddresses = <AddressModel>[].obs;
  final shippingAddress = ''.obs;
  final selectedAddressIndex = 0.obs;
  final isLoadingAddresses = false.obs;
  final isPlacingOrder = false.obs;
  final addressError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cartController = Get.find<CartController>();
    loadAddresses();
  }

  int get totalProductCount => cartController.itemCount;
  double get totalPrice => cartController.subtotal;
  double get discount => cartController.discount;
  double get deliveryFee => cartController.deliveryFee;
  double get totalPayable => cartController.total;

  AddressModel? get selectedAddress {
    if (savedAddresses.isEmpty) {
      return null;
    }
    final index = selectedAddressIndex.value;
    if (index < 0 || index >= savedAddresses.length) {
      return savedAddresses.first;
    }
    return savedAddresses[index];
  }

  Future<void> loadAddresses() async {
    try {
      isLoadingAddresses.value = true;
      addressError.value = '';
      final addresses = await _addressRepository.getMyAddresses();
      savedAddresses.assignAll(addresses);

      final defaultIndex = savedAddresses.indexWhere((item) => item.isDefault);
      selectedAddressIndex.value = defaultIndex >= 0 ? defaultIndex : 0;

      if (savedAddresses.isNotEmpty) {
        shippingAddress.value = (selectedAddress?.fullAddress ?? '').trim();
      } else {
        shippingAddress.value = '';
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load addresses', error, stackTrace);
      addressError.value = _resolveMessage(error, 'Failed to load addresses. Please try again.');
    } finally {
      isLoadingAddresses.value = false;
    }
  }

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
    final address = selectedAddress;
    if (address == null) {
      return;
    }

    shippingAddress.value = address.fullAddress;
    Get.back();
  }

  Future<void> goToPayment() async {
    if (cartController.cartItems.isEmpty) {
      return;
    }

    final address = selectedAddress;
    if (address == null || address.id.isEmpty) {
      Get.snackbar(
        'Address Required',
        'Please select a shipping address first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final orderItems = cartController.toOrderItems();
    if (orderItems.isEmpty) {
      Get.snackbar(
        'Unable to Continue',
        'Some cart items are missing variant information. Please refresh your cart and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.toNamed(
      Routes.PAYMENT,
      arguments: <String, dynamic>{
        'addressId': address.id,
        'shippingAddress': address.fullAddress,
      },
    );
  }

  String _resolveMessage(Object error, String fallback) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }
}
