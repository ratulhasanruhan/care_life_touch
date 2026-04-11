import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/custom_text_field.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'My Profile',
        backgroundColor: const Color(0xFFFFFCFC),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: controller.profileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: -0.02,
                    color: Color(0xFF01060F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Update your account information and business documents.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: Color(0xB3010614),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildProfileImageSection(),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: controller.shopNameController,
                  hintText: 'Shop Name *',
                  prefixIcon: const Icon(Icons.store_outlined),
                  validator: (value) =>
                      controller.validateRequiredField(value, 'shop name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.ownerNameController,
                  hintText: 'Owner Name *',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) =>
                      controller.validateRequiredField(value, 'owner name'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.phoneController,
                  hintText: 'Phone Number *',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  validator: controller.validatePhone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                _buildDocumentUploadSection(
                  title: 'Drug License',
                  imageType: 'drug_license',
                  imageFile: controller.drugLicenseImage,
                ),
                const SizedBox(height: 16),
                _buildDocumentUploadSection(
                  title: 'Trade License',
                  imageType: 'trade_license',
                  imageFile: controller.tradeLicenseImage,
                ),
                const SizedBox(height: 16),
                _buildDocumentUploadSection(
                  title: 'NID',
                  imageType: 'nid',
                  imageFile: controller.nidImage,
                ),
                const SizedBox(height: 16),
                _buildShopImagesSection(),
                const SizedBox(height: 24),
                Obx(
                  () => CustomButton(
                    text: 'Update Profile',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.updateProfile,
                    isLoading: controller.isLoading.value,
                    fullWidth: true,
                    size: ButtonSize.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadSection({
    required String title,
    required String imageType,
    required Rx<File?> imageFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.43,
            color: Color(0xFF01060F),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedImage = imageFile.value;
          if (selectedImage != null) {
            return GestureDetector(
              onTap: () => controller.pickImage(imageType),
              child: Container(
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  border: Border.all(color: const Color(0xFFE8EAE8)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildDocumentPreview(selectedImage),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(imageType),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: () => controller.pickImage(imageType),
            child: Container(
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: Border.all(color: const Color(0xFFE8EAE8)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildUploadPlaceholder(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Profile Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.43,
            color: Color(0xFF01060F),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedImage = controller.profileImage.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => controller.pickImage('profile'),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFF6F6F6),
                  child: ClipOval(
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: selectedImage == null
                          ? const Icon(
                              Icons.person_outline,
                              size: 48,
                              color: Color(0xFF064E36),
                            )
                          : _buildProfilePreview(selectedImage),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -2,
                child: GestureDetector(
                  onTap: () => controller.pickImage('profile'),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E36),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              if (selectedImage != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => controller.removeImage('profile'),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProfilePreview(File imageFile) {
    final path = imageFile.path;
    final isRemote = path.startsWith('http://') || path.startsWith('https://');

    if (isRemote) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.person_outline,
          size: 48,
          color: Color(0xFF064E36),
        ),
      );
    }

    return Image.file(
      imageFile,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.person_outline, size: 48, color: Color(0xFF064E36)),
    );
  }

  Widget _buildDocumentPreview(File imageFile) {
    final path = imageFile.path;
    final isRemote = path.startsWith('http://') || path.startsWith('https://');

    if (isRemote) {
      return Image.network(
        path,
        width: double.infinity,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildUploadPlaceholder(),
      );
    }

    return Image.file(
      imageFile,
      width: double.infinity,
      height: 112,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildUploadPlaceholder(),
    );
  }

  Widget _buildShopImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.43,
            color: Color(0xFF01060F),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final items = controller.shopImages;

          return SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return GestureDetector(
                    onTap: () => controller.pickImage('shop'),
                    child: Container(
                      width: 112,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: const Color(0xFFE8EAE8)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF064E36),
                        size: 28,
                      ),
                    ),
                  );
                }

                final path = items[index].path;
                final isRemote =
                    path.startsWith('http://') || path.startsWith('https://');

                return Container(
                  width: 112,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    border: Border.all(color: const Color(0xFFE8EAE8)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isRemote
                            ? Image.network(
                                path,
                                width: 112,
                                height: 112,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildUploadPlaceholder(),
                              )
                            : Image.file(
                                items[index],
                                width: 112,
                                height: 112,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildUploadPlaceholder(),
                              ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => controller.removeShopImageAt(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/upload_image.svg',
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.43,
              color: Color(0xB30A0A0A),
            ),
          ),
        ],
      ),
    );
  }
}
