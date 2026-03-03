import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_text_field.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../routes/app_pages.dart';
import '../controllers/auth_controller.dart';

/// Register View - User registration screen
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
                const SizedBox(height: 60),

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
                    color: Color(0xFF01060F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 44),

                // Full Name field
                CustomTextField(
                  controller: controller.nameController,
                  hintText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: controller.validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email field
                CustomTextField(
                  controller: controller.emailController,
                  hintText: 'Enter Your Email Address or Phone Number',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                Obx(() => CustomTextField(
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
                      color: AppColors.inner,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                )),
                const SizedBox(height: 16),

                // Confirm Password field
                Obx(() => CustomTextField(
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
                      color: AppColors.inner,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                )),
                const SizedBox(height: 24),

                // Register button
                Obx(() => CustomButton(
                  text: 'Confirm',
                  onPressed: controller.isLoading.value ? null : controller.register,
                  isLoading: controller.isLoading.value,
                  fullWidth: true,
                  size: ButtonSize.large,
                )),
                const SizedBox(height: 32),

                // Login link
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Have an account? ',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            color: Color(0xFF01060F),
                          ),
                        ),
                        TextSpan(
                          text: 'Log In Now',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            color: Color(0xFF064E36),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.toNamed(Routes.LOGIN),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


