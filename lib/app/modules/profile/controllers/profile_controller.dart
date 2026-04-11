import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;

  final profileFormKey = GlobalKey<FormState>();

  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();

  final Rx<File?> drugLicenseImage = Rx<File?>(null);
  final Rx<File?> tradeLicenseImage = Rx<File?>(null);
  final Rx<File?> nidImage = Rx<File?>(null);
  final Rx<File?> profileImage = Rx<File?>(null);
  final shopImages = <File>[].obs;

  final ImagePicker _picker = ImagePicker();
  final _storage = Get.find<StorageService>();
  final _authRepository = Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    _refreshProfileFromServer();
  }

  void _loadProfile() {
    final user = _storage.getUser();
    if (user == null) {
      return;
    }

    shopNameController.text =
        _firstNonEmptyString(<dynamic>[user['shopName'], user['shop_name']]) ?? '';
    ownerNameController.text = _firstNonEmptyString(<dynamic>[
          user['ownerName'],
          user['owner_name'],
          user['fullName'],
          user['full_name'],
          user['name'],
        ]) ??
        '';
    phoneController.text =
        _firstNonEmptyString(<dynamic>[user['phone'], user['phoneNumber'], user['phone_number']]) ?? '';

    _setImagePath(
      _firstNonEmptyString(<dynamic>[
        user['drugLicenseImage'],
        user['drugLicense'],
        user['drug_license'],
      ]),
      drugLicenseImage,
    );
    _setImagePath(
      _firstNonEmptyString(<dynamic>[
        user['tradeLicenseImage'],
        user['tradeLicense'],
        user['trade_license'],
      ]),
      tradeLicenseImage,
    );
    _setImagePath(
      _firstNonEmptyString(<dynamic>[user['nidImage'], user['nid_image'], user['nid']]),
      nidImage,
    );
    _setImagePath(
      _firstNonEmptyString(<dynamic>[user['profileImage'], user['profile_image'], user['avatar']]),
      profileImage,
    );

    shopImages.clear();
    final dynamic rawShopImages = user['shopImages'];
    if (rawShopImages is List) {
      for (final item in rawShopImages) {
        final path = (item ?? '').toString().trim();
        if (path.isNotEmpty) {
          shopImages.add(File(path));
        }
      }
    }

    if (shopImages.isEmpty) {
      final legacyPath = _firstNonEmptyString(<dynamic>[user['shopImage'], user['shop_image']]) ?? '';
      if (legacyPath.isNotEmpty) {
        shopImages.add(File(legacyPath));
      }
    }
  }

  void _setImagePath(dynamic path, Rx<File?> target) {
    final imagePath = (path ?? '').toString().trim();
    if (imagePath.isEmpty || imagePath.toLowerCase() == 'null') {
      return;
    }
    target.value = File(imagePath);
  }

  String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
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

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validate inputs
    if (oldPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your current password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (newPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your new password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (newPassword.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      Get.snackbar(
        'Success',
        'Password changed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();
      // Clear stored user data
      await _storage.logout();
      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      AppLogger.error('Logout failed', e);
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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

  Future<void> updateProfile() async {
    final isValid = profileFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    try {
      isLoading.value = true;

      final existingUser = _storage.getUser() ?? <String, dynamic>{};

      final uploadedProfileImage = await _resolveUpload(profileImage.value);
      final uploadedNid = await _resolveUpload(nidImage.value);
      final uploadedShopImages = await _resolveUploads(shopImages);

      await _authRepository.updateBuyerProfile(
        shopName: shopNameController.text.trim(),
        fullName: ownerNameController.text.trim(),
        profileImage: uploadedProfileImage,
        nidImage: uploadedNid,
        shopImages: uploadedShopImages.isEmpty ? null : uploadedShopImages,
      );

      final latestUser = await _authRepository.accessMe();
      await _storage.saveUser({
        ...existingUser,
        ...latestUser,
        'shopName': shopNameController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'profileImage': uploadedProfileImage ?? existingUser['profileImage'],
        'nidImage': uploadedNid ?? existingUser['nidImage'],
        'shopImages': uploadedShopImages.isEmpty
            ? (existingUser['shopImages'] ?? const <String>[])
            : uploadedShopImages,
        'shopImage': uploadedShopImages.isEmpty
            ? existingUser['shopImage']
            : uploadedShopImages.first,
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
        e is ApiException && e.message.trim().isNotEmpty
            ? e.message
            : 'Failed to update profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshProfileFromServer() async {
    if (!_storage.isLoggedIn) {
      return;
    }

    try {
      final profile = await _authRepository.accessMe();
      final existing = _storage.getUser() ?? <String, dynamic>{};
      await _storage.saveUser({...existing, ...profile});
      _loadProfile();
    } catch (_) {
      // Keep local cached profile when refresh fails.
    }
  }

  Future<String?> _resolveUpload(File? file) async {
    if (file == null) {
      return null;
    }
    if (file.path.startsWith('http://') || file.path.startsWith('https://')) {
      return file.path;
    }
    return _authRepository.uploadImage(file);
  }

  Future<List<String>> _resolveUploads(List<File> files) async {
    if (files.isEmpty) {
      return const [];
    }

    final uploaded = <String>[];
    for (final file in files) {
      if (file.path.startsWith('http://') || file.path.startsWith('https://')) {
        uploaded.add(file.path);
      } else {
        uploaded.add(await _authRepository.uploadImage(file));
      }
    }
    return uploaded;
  }

  Future<void> pickImage(String imageType) async {
    try {
      final source = await _showImageSourceBottomSheet();
      if (source == null) {
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 60,
      );

      if (pickedFile == null) {
        return;
      }

      final imageFile = File(pickedFile.path);
      switch (imageType) {
        case 'profile':
          profileImage.value = imageFile;
          break;
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
          shopImages.add(imageFile);
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

  void removeShopImageAt(int index) {
    if (index < 0 || index >= shopImages.length) {
      return;
    }
    shopImages.removeAt(index);
  }

  void removeImage(String imageType) {
    switch (imageType) {
      case 'profile':
        profileImage.value = null;
        break;
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
        shopImages.clear();
        break;
    }
  }

  @override
  void onClose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
