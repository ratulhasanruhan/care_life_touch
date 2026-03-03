import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/app_logger.dart';
import '../../../global_widgets/info_modal.dart';
import '../../../routes/app_pages.dart';
import '../models/profile_completion_model.dart';

/// Profile Completion Controller - Handles profile completion logic
class ProfileCompletionController extends GetxController {
  final isLoading = false.obs;

  // Form controllers
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Image files
  final Rx<File?> drugLicenseImage = Rx<File?>(null);
  final Rx<File?> tradeLicenseImage = Rx<File?>(null);
  final Rx<File?> nidImage = Rx<File?>(null);
  final Rx<File?> shopImage = Rx<File?>(null);

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    super.onClose();
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

  /// Submit profile completion
  Future<void> submitProfile() async {
    // if (!formKey.currentState!.validate()) {
    //   return;
    // }
    //
    // // Check if all images are uploaded
    // if (drugLicenseImage.value == null) {
    //   Get.snackbar(
    //     'Error',
    //     'Please upload Drug License image',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }
    //
    // if (tradeLicenseImage.value == null) {
    //   Get.snackbar(
    //     'Error',
    //     'Please upload Trade License image',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }
    //
    // if (nidImage.value == null) {
    //   Get.snackbar(
    //     'Error',
    //     'Please upload NID image',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }
    //
    // if (shopImage.value == null) {
    //   Get.snackbar(
    //     'Error',
    //     'Please upload Shop image',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    try {
      isLoading.value = true;
      AppLogger.info('Submitting profile completion');

      // Simulate API call - upload images and profile data
      await Future.delayed(const Duration(seconds: 3));

      // TODO: Replace with actual API call
      // final profile = ProfileCompletion(
      //   shopName: shopNameController.text,
      //   ownerName: ownerNameController.text,
      //   phone: phoneController.text,
      //   drugLicenseImage: drugLicenseImage.value,
      //   tradeLicenseImage: tradeLicenseImage.value,
      //   nidImage: nidImage.value,
      //   shopImage: shopImage.value,
      // );
      // final response = await profileRepository.completeProfile(profile);
      // Upload images to server
      // await profileRepository.uploadImages([...]);

      AppLogger.success('Profile completed successfully');

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

      // Navigate to home
      await Future.delayed(const Duration(milliseconds: 1000));
      Get.offAllNamed(Routes.HOME);

    } catch (e, stackTrace) {
      AppLogger.error('Profile completion failed', e, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to complete profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cancel profile completion
  void cancelProfile() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Profile Setup'),
        content: const Text(
          'Are you sure you want to cancel? You need to complete your profile to use the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous screen
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Validate shop name
  String? validateShopName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter shop name';
    }
    if (value.length < 3) {
      return 'Shop name must be at least 3 characters';
    }
    return null;
  }

  /// Validate owner name
  String? validateOwnerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter owner name';
    }
    if (value.length < 2) {
      return 'Owner name must be at least 2 characters';
    }
    return null;
  }

  /// Validate phone
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    // Bangladesh phone number validation (11 digits starting with 01)
    final phoneRegex = RegExp(r'^01[3-9]\d{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (e.g., 01712345678)';
    }
    return null;
  }
}


