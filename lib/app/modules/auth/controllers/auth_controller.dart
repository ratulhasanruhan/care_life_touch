import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../global_widgets/otp_verification_dialog.dart';

/// Auth Controller - Handles authentication logic
class AuthController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  // Form keys
  final registerFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  // OTP related
  final otpSent = false.obs;
  final otpVerified = false.obs;
  final resendTimer = 60.obs;

  final _storage = Get.find<StorageService>();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Register user
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      AppLogger.info('Registering user: ${emailController.text}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      // final response = await authRepository.register(
      //   name: nameController.text,
      //   email: emailController.text,
      //   password: passwordController.text,
      // );

      // Send OTP
      await sendOTP();

      AppLogger.success('Registration successful, OTP sent');
      Get.snackbar(
        'Success',
        'OTP sent to ${emailController.text}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Show OTP bottom sheet
      _showOTPBottomSheet();

    } catch (e, stackTrace) {
      AppLogger.error('Registration failed', e, stackTrace);
      Get.snackbar(
        'Error',
        'Registration failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Send OTP
  Future<void> sendOTP() async {
    try {
      AppLogger.info('Sending OTP to: ${emailController.text}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // await authRepository.sendOTP(email: emailController.text);

      otpSent.value = true;
      startResendTimer();

      AppLogger.success('OTP sent successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send OTP', e, stackTrace);
      rethrow;
    }
  }

  /// Verify OTP
  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty || otpController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Please enter valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      AppLogger.info('Verifying OTP: ${otpController.text}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // final response = await authRepository.verifyOTP(
      //   email: emailController.text,
      //   otp: otpController.text,
      // );

      // For demo, accept any 6-digit OTP
      if (otpController.text.length == 6) {
        otpVerified.value = true;

        // Save auth data
        await _storage.saveToken('demo_token_${DateTime.now().millisecondsSinceEpoch}');
        await _storage.saveUser({
          'name': nameController.text,
          'email': emailController.text,
        });

        AppLogger.success('OTP verified successfully');

        Get.back(); // Close OTP bottom sheet

        Get.snackbar(
          'Success',
          'Registration completed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to profile completion
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.PROFILE_COMPLETION);
      } else {
        throw Exception('Invalid OTP');
      }

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
  Future<void> resendOTP() async {
    if (resendTimer.value > 0) {
      return;
    }

    try {
      otpController.clear();
      await sendOTP();

      Get.snackbar(
        'Success',
        'OTP resent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Start resend timer
  void startResendTimer() {
    resendTimer.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      }
      return false;
    });
  }

  /// Show OTP dialog
  void _showOTPBottomSheet() {
    OTPVerificationDialog.show(
      email: emailController.text,
      onVerify: (pin) async {
        otpController.text = pin;
        await verifyOTP();
      },
      onResend: resendOTP,
      onEdit: () {
        Get.back();
        // Focus on email field or allow editing
      },
      resendTimer: resendTimer,
      isLoading: isLoading,
      otpLength: 6,
    );
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}


