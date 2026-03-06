import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/custom_text_field.dart';
import '../../../routes/app_pages.dart';
import '../controllers/auth_controller.dart';

/// Register View - User registration screen with complete profile
class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Sign Up Title
                const Text(
                  'Sign Up',
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

                // Subtitle
                const Text(
                  'Create your account to access trusted healthcare services.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: Color(0xB3010614),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Shop Name field
                CustomTextField(
                  controller: controller.shopNameController,
                  hintText: 'Shop Name *',
                  prefixIcon: const Icon(Icons.store_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Owner Name field
                CustomTextField(
                  controller: controller.ownerNameController,
                  hintText: 'Owner Name *',
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Phone Number field
                CustomTextField(
                  controller: controller.phoneController,
                  hintText: 'Phone Number *',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email field
                CustomTextField(
                  controller: controller.emailController,
                  hintText: 'Enter Your Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    hintText: 'Enter Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: !controller.isPasswordVisible.value,
                    validator: controller.validatePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    hintText: 'Retype your Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    validator: controller.validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Drug License Upload
                _buildDocumentUploadSection(
                  title: 'Drug License',
                  imageType: 'drug_license',
                  imageFile: controller.drugLicenseImage,
                ),
                const SizedBox(height: 16),

                // Trade License Upload
                _buildDocumentUploadSection(
                  title: 'Trade License',
                  imageType: 'trade_license',
                  imageFile: controller.tradeLicenseImage,
                ),
                const SizedBox(height: 16),

                // NID Upload
                _buildDocumentUploadSection(
                  title: 'NID',
                  imageType: 'nid',
                  imageFile: controller.nidImage,
                ),
                const SizedBox(height: 16),

                // Shop Image Upload
                _buildDocumentUploadSection(
                  title: 'Shop Image',
                  imageType: 'shop',
                  imageFile: controller.shopImage,
                ),
                const SizedBox(height: 24),

                // Register button (inside scrollable content)
                Obx(
                  () => CustomButton(
                    text: 'Confirm',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.register,
                    isLoading: controller.isLoading.value,
                    fullWidth: true,
                    size: ButtonSize.large,
                  ),
                ),
                const SizedBox(height: 16),

                // Login link
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF01060F),
                        ),
                      ),
                      TextSpan(
                        text: 'Log In Now',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF064E36),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed(Routes.LOGIN),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build document upload section
  Widget _buildDocumentUploadSection({
    required String title,
    required String imageType,
    required Rx<File?> imageFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
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

        // Upload area
        Obx(() {
          final hasImage = imageFile.value != null;

          if (hasImage) {
            return Container(
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
                    child: Image.file(
                      imageFile.value!,
                      width: double.infinity,
                      height: 112,
                      fit: BoxFit.cover,
                    ),
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
            );
          }

          return GestureDetector(
            onTap: () => controller.pickImage(imageType),
            child: Container(
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: Border.all(
                  color: const Color(0xFFE8EAE8),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
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
              ),
            ),
          );
        }),
      ],
    );
  }
}
