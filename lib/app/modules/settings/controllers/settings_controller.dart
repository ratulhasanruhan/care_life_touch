import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/storage_provider.dart';
import '../../../routes/app_pages.dart';

class SettingsController extends GetxController {
  final _storage = Get.find<StorageService>();

  void changePassword() {
    Get.toNamed(Routes.CHANGE_PASSWORD);
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _storage.logout();
              Get.back();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

