import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_text_field.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/info_modal.dart';
import '../../../routes/app_pages.dart';
import '../controllers/forgot_password_controller.dart';

/// Reset Password View - New password entry screen
class ResetPasswordView extends GetView<ForgotPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Create New Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Please enter your new password. Make sure it\'s different from your previous password.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF43505C),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // New Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.newPasswordController,
                    hintText: 'Enter your new password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: !controller.isPasswordVisible.value,
                    validator: controller.validatePassword,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.inner,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password field
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    validator: controller.validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.inner,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Reset Password button
                Obx(
                  () => CustomButton(
                    text: 'Save',
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            await controller.resetPassword();
                            // Show success modal
                            if (!controller.isLoading.value) {
                              await InfoModal.show(
                                title: 'Password Updated!',
                                description:
                                    'Your password has been set up successfully.',
                                buttonText: 'Back to Log In',
                                imagePath: 'assets/images/ic_new_pass.png',
                                onPressed: () {
                                  Get.back(); // Close modal
                                  Get.offAllNamed(
                                    Routes.LOGIN,
                                  ); // Navigate to login
                                },
                              );
                            }
                          },
                    isLoading: controller.isLoading.value,
                    fullWidth: true,
                    size: ButtonSize.large,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
