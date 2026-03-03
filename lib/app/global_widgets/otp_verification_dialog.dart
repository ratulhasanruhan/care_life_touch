import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../core/values/app_colors.dart';

/// OTP Verification Dialog Widget
/// 
/// A reusable dialog for OTP verification that can be used across different flows
/// like registration, forgot password, phone verification, etc.
/// 
/// Features:
/// - Clean Material Design with rounded corners
/// - Back button for navigation
/// - Email display with optional edit functionality
/// - 6-digit OTP input using Pinput package
/// - Resend timer with countdown
/// - Auto-submit on completion
/// 
/// Example Usage:
/// ```dart
/// // In Registration Flow
/// OTPVerificationDialog.show(
///   email: emailController.text,
///   onVerify: (pin) async {
///     await authController.verifyRegistrationOTP(pin);
///   },
///   onResend: () => authController.resendOTP(),
///   onEdit: () {
///     Get.back();
///     // Navigate back to email input
///   },
///   resendTimer: authController.resendTimer,
///   isLoading: authController.isLoading,
///   otpLength: 6,
/// );
/// 
/// // In Forgot Password Flow
/// OTPVerificationDialog.show(
///   email: forgotPasswordEmail,
///   onVerify: (pin) async {
///     await passwordController.verifyResetOTP(pin);
///   },
///   onResend: () => passwordController.resendResetOTP(),
///   resendTimer: passwordController.otpTimer,
///   isLoading: passwordController.isLoading,
/// );
/// ```
class OTPVerificationDialog extends StatelessWidget {
  final String email;
  final Function(String) onVerify;
  final VoidCallback onResend;
  final VoidCallback? onEdit;
  final RxInt resendTimer;
  final RxBool isLoading;
  final int otpLength;

  const OTPVerificationDialog({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onResend,
    this.onEdit,
    required this.resendTimer,
    required this.isLoading,
    this.otpLength = 6,
  });

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 358,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F4F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: AppColors.shade50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Enter verification code',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: Color(0xFF01060F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Enter the $otpLength-digit code sent we sent to',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color.fromRGBO(25, 25, 48, 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Email with Edit option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: Color(0xFF01060F),
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),

            // OTP Input using Pinput
            Pinput(
              controller: otpController,
              length: otpLength,
              defaultPinTheme: PinTheme(
                width: 40,
                height: 40,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF01060F),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: Color(0xFFE8EAE8), width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 40,
                height: 40,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF01060F),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.primary500, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              submittedPinTheme: PinTheme(
                width: 40,
                height: 40,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF01060F),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: Color(0xFFE8EAE8), width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              errorPinTheme: PinTheme(
                width: 40,
                height: 40,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF01060F),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.error),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              onCompleted: (pin) {
                onVerify(pin);
              },
            ),
            const SizedBox(height: 20),

            // Resend Code Timer
            Obx(
              () => Text(
                resendTimer.value > 0
                    ? 'Resend Code in 00:${resendTimer.value.toString().padLeft(2, '0')}'
                    : 'Resend Code',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: resendTimer.value > 0
                      ? const Color.fromRGBO(1, 6, 15, 0.7)
                      : AppColors.primary,
                ),
              ),
            ),
            if (resendTimer.value == 0)
              TextButton(
                onPressed: onResend,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Tap to resend',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Static method to show the dialog
  static Future<void> show({
    required String email,
    required Function(String) onVerify,
    required VoidCallback onResend,
    VoidCallback? onEdit,
    required RxInt resendTimer,
    required RxBool isLoading,
    int otpLength = 6,
  }) {
    return Get.dialog(
      OTPVerificationDialog(
        email: email,
        onVerify: onVerify,
        onResend: onResend,
        onEdit: onEdit,
        resendTimer: resendTimer,
        isLoading: isLoading,
        otpLength: otpLength,
      ),
      barrierDismissible: false,
    );
  }
}




