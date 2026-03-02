import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../routes/app_pages.dart';

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
    if (otpController.text.isEmpty || otpController.text.length < 4) {
      Get.snackbar(
        'Error',
        'Please enter valid OTP',
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

      // For demo, accept any 4-digit OTP
      if (otpController.text.length == 4) {
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

  /// Show OTP bottom sheet
  void _showOTPBottomSheet() {
    Get.bottomSheet(
      _buildOTPBottomSheet(),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  /// Build OTP bottom sheet widget
  Widget _buildOTPBottomSheet() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF01060F),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Enter the 4-digit code sent to\n${emailController.text}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF43505C),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // OTP Input
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 16,
              ),
              decoration: InputDecoration(
                hintText: '----',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8EAEB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE8EAEB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF064E36), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resend OTP
            Center(
              child: Obx(() => resendTimer.value > 0
                ? Text(
                    'Resend OTP in ${resendTimer.value}s',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF43505C),
                    ),
                  )
                : TextButton(
                    onPressed: resendOTP,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF064E36),
                      ),
                    ),
                  ),
              ),
            ),
            const SizedBox(height: 16),

            // Verify Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Verify & Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
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


