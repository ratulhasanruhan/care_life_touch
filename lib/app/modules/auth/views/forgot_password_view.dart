import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_text_field.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/otp_verification_dialog.dart';
import '../controllers/forgot_password_controller.dart';

/// Forgot Password View - Email entry screen
class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.emailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Title
                const Text(
                  'Forget Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Enter the email associated with your account and we\'ll send an email with instructions to reset your password.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF01060F).withValues(alpha: 0.7),
                    height: 1.43,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email field
                CustomTextField(
                  controller: controller.emailController,
                  hintText: 'Enter Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                // Confirm button
                Obx(
                  () => CustomButton(
                    text: 'Confirm',
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (!controller.emailFormKey.currentState!
                                .validate()) {
                              return;
                            }
                            controller.sendPasswordResetOTP();
                            // Show OTP dialog
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                OTPVerificationDialog.show(
                                  email: controller.emailController.text,
                                  onVerify: (pin) {
                                    controller.verifyPasswordResetOTP(pin);
                                  },
                                  onResend: () {
                                    controller.resendPasswordResetOTP();
                                  },
                                  onEdit: () {
                                    Get.back();
                                    controller.otpSent.value = false;
                                  },
                                  resendTimer: controller.resendTimer,
                                  isLoading: controller.isLoading,
                                  otpLength: 6,
                                );
                              },
                            );
                          },
                    isLoading: controller.isLoading.value,
                    fullWidth: true,
                    size: ButtonSize.large,
                  ),
                ),
                const SizedBox(height: 20),

                // Back to login
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Back To Log In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
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
