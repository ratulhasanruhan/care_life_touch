import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../legal/routes.dart';
import '../../../routes/app_pages.dart';

class MoreController extends GetxController {
  // User information
  final userName = 'Guest User'.obs;
  final userImage = ''.obs;

  // Loading states
  final isLoading = false.obs;

  final _storage = Get.find<StorageService>();
  final _authRepository = Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    // Load user data
    _loadUserData();
  }

  void _loadUserData() {
    final user = _storage.getUser();

    userName.value =
        (user?['ownerName'] ?? user?['name'] ?? 'Guest User').toString();
    userImage.value =
        (user?['profileImage'] ?? user?['shopImage'] ?? '').toString();
  }

  // Navigation methods
  Future<void> navigateToProfile() async {
    final result = await Get.toNamed(Routes.PROFILE);
    if (result == true) {
      _loadUserData();
    }
  }

  void navigateToAddress() {
    // TODO: Add address route
    Get.snackbar('Coming Soon', 'Address management feature');
  }

  void navigateToOrders() {
    Get.toNamed(Routes.ORDER_HISTORY);
  }

  void navigateToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void navigateToAbout() {
    Get.toNamed(LegalRoutes.about);
  }

  void navigateToPrivacyPolicy() {
    Get.toNamed(LegalRoutes.privacy);
  }

  void navigateToTerms() {
    Get.toNamed(LegalRoutes.terms);
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
            onPressed: () async {
              await _authRepository.logout();
              await _storage.logout();
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
    navigateToProfile();
  }
}


