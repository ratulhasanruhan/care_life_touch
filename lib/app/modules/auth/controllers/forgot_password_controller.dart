import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
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


  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  @override
  void onClose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.onClose();
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

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // await passwordRepository.sendResetOTP(email: emailController.text);

      otpSent.value = true;
      resendTimer.value = 60;
      _startResendTimer();

      AppLogger.success('Password reset OTP sent successfully');


    } catch (e, stackTrace) {
      AppLogger.error('Failed to send OTP', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP for password reset
  Future<void> verifyPasswordResetOTP(String pin) async {
    try {
      isLoading.value = true;

      AppLogger.info('Verifying password reset OTP');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // await passwordRepository.verifyResetOTP(
      //   email: resetEmail.value,
      //   otp: pin,
      // );

      otpVerified.value = true;

      AppLogger.success('OTP verified successfully');

      // Close OTP dialog and navigate to new password screen
      Get.back(); // Close dialog
      Get.toNamed(Routes.FORGOT_PASSWORD_RESET, arguments: {
        'email': resetEmail.value,
      });

    } catch (e, stackTrace) {
      AppLogger.error('OTP verification failed', e, stackTrace);
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendPasswordResetOTP() async {
    try {
      AppLogger.info('Resending password reset OTP');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // await passwordRepository.sendResetOTP(email: resetEmail.value);

      resendTimer.value = 60;
      _startResendTimer();

      AppLogger.success('OTP resent successfully');

      Get.snackbar(
        'Success',
        'OTP resent to ${resetEmail.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e, stackTrace) {
      AppLogger.error('Failed to resend OTP', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to resend OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      // await passwordRepository.resetPassword(
      //   email: resetEmail.value,
      //   newPassword: newPasswordController.text,
      // );

      InfoModal.show(
        title: 'Congratulation',
        description: 'Your account is reedy to use. You will be redirected to the home page in a few seconds',
        buttonText: 'Go to Home',
        imagePath: 'assets/images/ic_profile_success.png',
        onPressed: () {
          Get.back(); // Close modal
          Get.offAllNamed(Routes.HOME); // Navigate to login
        },
      );

      AppLogger.success('Password reset successfully');


    } catch (e, stackTrace) {
      AppLogger.error('Password reset failed', e, stackTrace);
      Get.snackbar(
        'Error',
        'Password reset failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Start resend timer
  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
        _startResendTimer();
      }
    });
  }
}

