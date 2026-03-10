import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class MoreController extends GetxController {
  // User information
  final userName = 'John Deo'.obs;
  final userImage = ''.obs;

  // Loading states
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load user data
    _loadUserData();
  }

  void _loadUserData() {
    // TODO: Load user data from storage/API
  }

  // Navigation methods
  void navigateToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  void navigateToAddress() {
    // TODO: Add address route
    Get.snackbar('Coming Soon', 'Address management feature');
  }

  void navigateToOrders() {
    // TODO: Add orders route
    Get.snackbar('Coming Soon', 'Orders feature');
  }

  void navigateToSettings() {
    // TODO: Add settings route
    Get.snackbar('Coming Soon', 'Settings feature');
  }

  void navigateToAbout() {
    Get.toNamed('/legal/about');
  }

  void navigateToPrivacyPolicy() {
    Get.toNamed('/legal/privacy');
  }

  void navigateToTerms() {
    Get.toNamed('/legal/terms');
  }

  void signOut() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear user data
              Get.back();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void changePhoto() {
    // TODO: Implement photo picker
    Get.snackbar('Coming Soon', 'Photo upload feature');
  }

  @override
  void onClose() {
    super.onClose();
  }
}


