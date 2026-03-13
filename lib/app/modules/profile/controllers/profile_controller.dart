import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final profileFormKey = GlobalKey<FormState>();

  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final Rx<File?> drugLicenseImage = Rx<File?>(null);
  final Rx<File?> tradeLicenseImage = Rx<File?>(null);
  final Rx<File?> nidImage = Rx<File?>(null);
  final Rx<File?> shopImage = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();
  final _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  void _loadProfile() {
    final user = _storage.getUser();
    if (user == null) {
      return;
    }

    shopNameController.text = (user['shopName'] ?? '').toString();
    ownerNameController.text =
        (user['ownerName'] ?? user['name'] ?? '').toString();
    phoneController.text = (user['phone'] ?? '').toString();
    emailController.text = (user['email'] ?? '').toString();

    _setImageFromPath(user['drugLicenseImage'], drugLicenseImage);
    _setImageFromPath(user['tradeLicenseImage'], tradeLicenseImage);
    _setImageFromPath(user['nidImage'], nidImage);
    _setImageFromPath(user['shopImage'] ?? user['profileImage'], shopImage);
  }

  void _setImageFromPath(dynamic path, Rx<File?> target) {
    final imagePath = path?.toString();
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      target.value = file;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? validateRequiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if ((value == null || value.isEmpty) &&
        confirmPasswordController.text.isEmpty) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Please enter new password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (passwordController.text.isEmpty && (value == null || value.isEmpty)) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> updateProfile() async {
    final isValid = profileFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    try {
      isLoading.value = true;

      final existingUser = _storage.getUser() ?? <String, dynamic>{};

      await Future.delayed(const Duration(milliseconds: 500));

      await _storage.saveUser({
        ...existingUser,
        'id': (existingUser['id'] ?? DateTime.now().millisecondsSinceEpoch)
            .toString(),
        'name': ownerNameController.text.trim(),
        'shopName': shopNameController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'profileImage': shopImage.value?.path,
        'drugLicenseImage': drugLicenseImage.value?.path,
        'tradeLicenseImage': tradeLicenseImage.value?.path,
        'nidImage': nidImage.value?.path,
        'shopImage': shopImage.value?.path,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      AppLogger.success('Profile updated successfully');

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(result: true);
    } catch (e, stackTrace) {
      AppLogger.error('Profile update failed', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to update profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(String imageType) async {
    try {
      final source = await _showImageSourceBottomSheet();
      if (source == null) {
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final imageFile = File(pickedFile.path);
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

      AppLogger.success('Profile image picked: $imageType');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to pick profile image', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<ImageSource?> _showImageSourceBottomSheet() async {
    return Get.bottomSheet<ImageSource>(
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
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF064E36),
              ),
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
  }

  @override
  void onClose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

