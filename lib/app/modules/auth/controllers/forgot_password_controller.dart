import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../global_widgets/info_modal.dart';
import '../../../routes/app_pages.dart';

/// Forgot Password Controller - Handles password reset flow
class ForgotPasswordController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Form controllers
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  // Form keys
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  // OTP related
  final otpSent = false.obs;
  final otpVerified = false.obs;
  final resendTimer = 60.obs;

  // Current email for password reset
  final resetEmail = ''.obs;
  final _authRepository = Get.find<AuthRepository>();
  Timer? _resendTimerTicker;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['email'] != null) {
      final value = args['email'].toString();
      resetEmail.value = value;
      emailController.text = value;
    }
  }

  @override
  void onClose() {
    _resendTimerTicker?.cancel();
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Validate phone or email identifier
  String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone or Email is required';
    }

    final isPhone = RegExp(r'^(\+8801|8801|01)[0-9]{9}$').hasMatch(value.replaceAll('-', '').replaceAll(' ', ''));
    final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);

    if (!isPhone && !isEmail) {
      return 'Please enter a valid phone or email';
    }
    return null;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Send password reset OTP
  Future<void> sendPasswordResetOTP() async {
    if (!emailFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      resetEmail.value = emailController.text;

      AppLogger.info('Sending password reset OTP to: ${emailController.text}');

      await _authRepository.sendForgotPasswordOtp(
        identifier: emailController.text.trim(),
      );

      otpSent.value = true;
      resendTimer.value = 60;
      _startResendTimer();

      AppLogger.success('Password reset OTP sent successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send OTP', e, stackTrace);
      _showError(_resolveErrorMessage(e, fallback: 'Failed to send OTP. Please try again.'));
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP for password reset
  Future<void> verifyPasswordResetOTP(String pin) async {
    try {
      isLoading.value = true;

      AppLogger.info('Verifying password reset OTP');
      otpController.text = pin;

      otpVerified.value = true;

      AppLogger.success('OTP verified successfully');

      // Close OTP dialog and navigate to new password screen
      Get.back(); // Close dialog
      Get.toNamed(
        Routes.FORGOT_PASSWORD_RESET,
        arguments: {'email': resetEmail.value},
      );
    } catch (e, stackTrace) {
      AppLogger.error('OTP verification failed', e, stackTrace);
      _showError(_resolveErrorMessage(e, fallback: 'Invalid OTP. Please try again.'));
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendPasswordResetOTP() async {
    try {
      AppLogger.info('Resending password reset OTP');

      await _authRepository.sendForgotPasswordOtp(
        identifier: resetEmail.value,
      );

      resendTimer.value = 60;
      _startResendTimer();

      AppLogger.success('OTP resent successfully');

      AppHelpers.showSuccessSnackbar(message: 'OTP resent to ${resetEmail.value}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to resend OTP', e, stackTrace);
      _showError(_resolveErrorMessage(e, fallback: 'Failed to resend OTP. Please try again.'));
    }
  }

  /// Reset password with new password
  Future<void> resetPassword() async {
    if (!passwordFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      AppLogger.info('Resetting password');

      await _authRepository.resetPasswordWithOtp(
        identifier: resetEmail.value,
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      InfoModal.show(
        title: 'Password Updated!',
        description: 'Your password has been set up successfully.',
        buttonText: 'Back to Log In',
        imagePath: 'assets/images/ic_new_pass.png',
        onPressed: () {
          Get.back(); // Close modal
          Get.offAllNamed(Routes.LOGIN); // Navigate to login
        },
      );

      AppLogger.success('Password reset successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Password reset failed', e, stackTrace);
      _showError(_resolveErrorMessage(e, fallback: 'Password reset failed. Please try again.'));
    } finally {
      isLoading.value = false;
    }
  }

  /// Start resend timer
  void _startResendTimer() {
    _resendTimerTicker?.cancel();
    _resendTimerTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value <= 0) {
        timer.cancel();
        return;
      }
      resendTimer.value--;
    });
  }

  String _resolveErrorMessage(Object error, {required String fallback}) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }

  void _showError(String message) {
    AppHelpers.showErrorSnackbar(message: message);
  }
}
