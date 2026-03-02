import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF01060F),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Sign up to get started with Care Life Touch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF43505C),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Name field
                CustomTextField(
                  controller: controller.nameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: controller.validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Email field
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Password field
                Obx(() => CustomTextField(
                  controller: controller.passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: !controller.isPasswordVisible.value,
                  validator: controller.validatePassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF43505C),
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                )),
                const SizedBox(height: 32),

                // Terms and conditions
                Row(
                  children: [
                    const Text(
                      'By signing up, you agree to our ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF43505C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.TERMS),
                      child: const Text(
                        'Terms',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF064E36),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Text(
                      ' & ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF43505C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.PRIVACY),
                      child: const Text(
                        'Privacy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF064E36),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register button
                Obx(() => CustomButton(
                  text: 'Sign Up',
                  onPressed: controller.isLoading.value ? null : controller.register,
                  isLoading: controller.isLoading.value,
                  fullWidth: true,
                  size: ButtonSize.large,
                )),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.line,
                        thickness: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF43505C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.line,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Social login buttons
                _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  label: 'Continue with Google',
                  onPressed: () {
                    Get.snackbar('Info', 'Google login coming soon!');
                  },
                ),
                const SizedBox(height: 12),

                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Continue with Facebook',
                  onPressed: () {
                    Get.snackbar('Info', 'Facebook login coming soon!');
                  },
                ),
                const SizedBox(height: 32),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF43505C),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.LOGIN),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF064E36),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF01060F),
          side: const BorderSide(color: Color(0xFFE8EAEB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}


