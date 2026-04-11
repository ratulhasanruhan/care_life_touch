import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';

class ChangePasswordController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.toggle();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter current password';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter new password';
    }

    final passwordValidation = Validators.password(value.trim());
    if (passwordValidation != null) {
      return passwordValidation;
    }

    if (value.trim() == currentPasswordController.text.trim()) {
      return 'New password must be different';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please re-type new password';
    }

    return Validators.confirmPassword(value.trim(), newPasswordController.text.trim());
  }

  Future<void> changePassword() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    try {
      isLoading.value = true;
      await _authRepository.changePassword(
        oldPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );

      AppLogger.success('Password changed successfully');

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(result: true);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to change password', e, stackTrace);
      Get.snackbar(
        'Error',
        e is ApiException && e.message.trim().isNotEmpty
            ? e.message
            : 'Failed to change password. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

