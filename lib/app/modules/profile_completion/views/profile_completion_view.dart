import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_text_field.dart';
import '../../../global_widgets/custom_button.dart';
import '../controllers/profile_completion_controller.dart';

/// Profile Completion View - Screen for completing shop owner profile
class ProfileCompletionView extends GetView<ProfileCompletionController> {
  const ProfileCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header text
                      const Text(
                        'Shop & Owner Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF01060F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please provide your shop details and upload required documents to continue.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF43505C),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Shop Name
                      CustomTextField(
                        controller: controller.shopNameController,
                        labelText: 'Shop Name',
                        hintText: 'Enter your shop name',
                        prefixIcon: const Icon(Icons.store_outlined),
                        validator: controller.validateShopName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Owner Name
                      CustomTextField(
                        controller: controller.ownerNameController,
                        labelText: 'Owner Name',
                        hintText: 'Enter owner name',
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: controller.validateOwnerName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Phone Number
                      CustomTextField(
                        controller: controller.phoneController,
                        labelText: 'Phone Number',
                        hintText: 'Enter phone number (e.g., 01712345678)',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                        validator: controller.validatePhone,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 32),

                      // Documents Section
                      const Text(
                        'Required Documents',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF01060F),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Drug License
                      _buildImageUploadCard(
                        title: 'Drug License',
                        description: 'Upload your drug license document',
                        imageType: 'drug_license',
                        imageFile: controller.drugLicenseImage,
                        icon: Icons.medication_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Trade License
                      _buildImageUploadCard(
                        title: 'Trade License',
                        description: 'Upload your trade license document',
                        imageType: 'trade_license',
                        imageFile: controller.tradeLicenseImage,
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 16),

                      // NID
                      _buildImageUploadCard(
                        title: 'National ID (NID)',
                        description: 'Upload your National ID card',
                        imageType: 'nid',
                        imageFile: controller.nidImage,
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Shop Image
                      _buildImageUploadCard(
                        title: 'Shop Photo',
                        description: 'Upload a photo of your shop',
                        imageType: 'shop',
                        imageFile: controller.shopImage,
                        icon: Icons.storefront_outlined,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: controller.cancelProfile,
                        variant: ButtonVariant.secondary,
                        size: ButtonSize.large,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Submit Button
                    Expanded(
                      flex: 2,
                      child: Obx(() => CustomButton(
                        text: 'Submit',
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.submitProfile,
                        isLoading: controller.isLoading.value,
                        variant: ButtonVariant.primary,
                        size: ButtonSize.large,
                        fullWidth: true,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build image upload card widget
  Widget _buildImageUploadCard({
    required String title,
    required String description,
    required String imageType,
    required Rx<File?> imageFile,
    required IconData icon,
  }) {
    return Obx(() {
      final hasImage = imageFile.value != null;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.line,
            width: hasImage ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF01060F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF43505C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Image preview or upload button
            if (hasImage)
              Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Image preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile.value!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => controller.pickImage(imageType),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Change'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => controller.removeImage(imageType),
                                icon: const Icon(Icons.delete_outline, size: 16),
                                label: const Text('Remove'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: OutlinedButton.icon(
                  onPressed: () => controller.pickImage(imageType),
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text('Upload Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}



