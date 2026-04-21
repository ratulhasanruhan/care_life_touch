import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/app_colors.dart';

/// Helper class for showing snackbars and dialogs
class AppHelpers {
  AppHelpers._();

  /// Show success snackbar
  static void showSuccessSnackbar({
    required String message,
    String title = 'Success',
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar({
    required String message,
    String title = 'Error',
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar({
    required String message,
    String title = 'Info',
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info,
      colorText: AppColors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show warning snackbar
  static void showWarningSnackbar({
    required String message,
    String title = 'Warning',
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.warning,
      colorText: AppColors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show loading dialog
  static void showLoading({String message = 'Loading...'}) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
