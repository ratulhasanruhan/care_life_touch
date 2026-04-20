import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../legal/routes.dart';
import '../../../routes/app_pages.dart';
import '../../address/views/routes.dart';

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

  Future<void> _loadUserData() async {
    final localUser = _storage.getUser();

    try {
      final remoteUser = await _authRepository.accessMe();
      _applyUserData(remoteUser, fallback: localUser);
      return;
    } catch (_) {
      // Use cached local user data when the API is unavailable.
    }

    _applyUserData(localUser);
  }

  Future<void> refreshPage() async {
    await _loadUserData();
  }

  void _applyUserData(
    Map<String, dynamic>? user, {
    Map<String, dynamic>? fallback,
  }) {
    final resolvedName = _firstNonEmptyString(<dynamic>[
      user?['name'],
      user?['fullName'],
      user?['ownerName'],
      user?['shopName'],
      user?['phone'],
      user?['email'],
      fallback?['name'],
      fallback?['fullName'],
      fallback?['ownerName'],
      fallback?['shopName'],
      fallback?['phone'],
      fallback?['email'],
      _storage.getLastLoginIdentifier(),
    ]);

    userName.value = resolvedName ?? 'Guest User';
    userImage.value =
        _firstNonEmptyString(<dynamic>[
              user?['profileImage'],
              user?['profile_image'],
              user?['shopImage'],
              user?['shop_image'],
              user?['avatar'],
              user?['photo'],
              user?['image'],
              fallback?['profileImage'],
              fallback?['profile_image'],
              fallback?['shopImage'],
              fallback?['shop_image'],
              fallback?['avatar'],
              fallback?['photo'],
              fallback?['image'],
            ]) ??
        '';
  }

  String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  // Navigation methods
  Future<void> navigateToProfile() async {
    final result = await Get.toNamed(Routes.PROFILE);
    if (result == true) {
      _loadUserData();
    }
  }

  void navigateToAddress() {
    Get.toNamed(AddressRoutes.addresses);
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
