import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../global_widgets/info_modal.dart';

/// Auth Controller - Handles authentication logic
class AuthController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  // Profile completion fields
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();

  // Form keys
  final registerFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  // Image files
  final Rx<File?> drugLicenseImage = Rx<File?>(null);
  final Rx<File?> tradeLicenseImage = Rx<File?>(null);
  final Rx<File?> nidImage = Rx<File?>(null);
  final Rx<File?> shopImage = Rx<File?>(null);

  // Image picker
  final ImagePicker _picker = ImagePicker();

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
    confirmPasswordController.dispose();
    otpController.dispose();
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Register user
  Future<void> register() async {
    // Basic validation for required fields
    if (shopNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter shop name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (ownerNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter owner name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please confirm your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      AppLogger.info('Registering user: ${emailController.text}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual API call
      // final response = await authRepository.register(
      //   shopName: shopNameController.text,
      //   ownerName: ownerNameController.text,
      //   phone: phoneController.text,
      //   email: emailController.text,
      //   password: passwordController.text,
      //   drugLicense: drugLicenseImage.value,
      //   tradeLicense: tradeLicenseImage.value,
      //   nid: nidImage.value,
      //   shopImage: shopImage.value,
      // );

      // Save auth data
      await _storage.saveToken('demo_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storage.saveUser({
        'shopName': shopNameController.text,
        'ownerName': ownerNameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
      });

      AppLogger.success('Registration successful');

      isLoading.value = false;

      // Show success modal
      InfoModal.show(
        title: 'Congratulation',
        description: 'Your account is ready to use. You will be redirected to the home page in a few seconds',
        buttonText: 'Go to Home',
        imagePath: 'assets/images/ic_profile_success.png',
        onPressed: () {
          Get.back(); // Close modal
          Get.offAllNamed(Routes.HOME); // Navigate to home
        },
      );

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

        // Navigate to home
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.HOME);
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
    final emailRegex = RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$');
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

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Pick image from camera or gallery
  Future<void> pickImage(String imageType) async {
    try {
      // Show bottom sheet to choose between camera and gallery
      final source = await _showImageSourceBottomSheet();

      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        switch (imageType) {
          case 'drug_license':
            drugLicenseImage.value = imageFile;
            break;
          case 'trade_license':
            tradeLicenseImage.value = imageFile;
            break;
          case 'nid':
            nidImage.value = imageFile;
            break;
          case 'shop':
            shopImage.value = imageFile;
            break;
        }

        AppLogger.success('Image picked: $imageType');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to pick image', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show image source selection bottom sheet
  Future<ImageSource?> _showImageSourceBottomSheet() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF01060F),
              ),
            ),
            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF064E36)),
              title: const Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),

            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF064E36)),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  /// Remove image
  void removeImage(String imageType) {
    switch (imageType) {
      case 'drug_license':
        drugLicenseImage.value = null;
        break;
      case 'trade_license':
        tradeLicenseImage.value = null;
        break;
      case 'nid':
        nidImage.value = null;
        break;
      case 'shop':
        shopImage.value = null;
        break;
    }
    AppLogger.info('Image removed: $imageType');
  }
}


