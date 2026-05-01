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
///   identifier: emailController.text,
///   onVerify: (pin) async {
///     await authController.verifyRegistrationOTP(pin);
///   },
///   resendTimer: authController.resendTimer,
///   isLoading: authController.isLoading,
///   title: 'Enter OTP',
///   subtitle: 'Enter the OTP provided by admin to complete registration.',
///   showResendButton: false,
///   otpLength: 6,
/// );
///
/// // In Forgot Password Flow
/// OTPVerificationDialog.show(
///   identifier: forgotPasswordEmail,
///   onVerify: (pin) async {
///     await passwordController.verifyResetOTP(pin);
///   },
///   onResend: () => passwordController.resendResetOTP(),
///   onEdit: () {
///     Get.back();
///     // Navigate back to phone/email input
///   },
///   resendTimer: passwordController.otpTimer,
///   isLoading: passwordController.isLoading,
///   showIdentifier: true,
/// );
/// ```
class OTPVerificationDialog extends StatelessWidget {
  final String identifier;
  final Function(String) onVerify;
  final VoidCallback? onResend;
  final VoidCallback? onEdit;
  final RxInt resendTimer;
  final RxBool isLoading;
  final int otpLength;
  final String title;
  final String subtitle;
  final bool showResendButton;
  final bool showIdentifier;

  const OTPVerificationDialog({
    super.key,
    required this.identifier,
    required this.onVerify,
    this.onResend,
    this.onEdit,
    required this.resendTimer,
    required this.isLoading,
    this.otpLength = 6,
    this.title = 'Enter verification code',
    this.subtitle = 'Care Life Touch will contact you for your OTP.',
    this.showResendButton = true,
    this.showIdentifier = false,
  });

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: Color(0xFF01060F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color.fromRGBO(25, 25, 48, 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (showIdentifier && identifier.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                identifier.trim(),
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF01060F),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onEdit != null && showIdentifier) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
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

            if (showResendButton) ...[
              // Resend Code Button with countdown
              Obx(
                () {
                  final canResend = resendTimer.value == 0 && onResend != null;
                  final isBusy = isLoading.value;
                  final label = resendTimer.value == 0
                      ? 'Tap to resend OTP'
                      : 'Resend Code in ${resendTimer.value}s';

                  return TextButton(
                    onPressed: canResend && !isBusy ? onResend : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight:
                            canResend && !isBusy ? FontWeight.w500 : FontWeight.w400,
                        color:
                            canResend && !isBusy ? AppColors.primary : const Color.fromRGBO(1, 6, 15, 0.7),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Static method to show the dialog
  static Future<void> show({
    required String identifier,
    required Function(String) onVerify,
    VoidCallback? onResend,
    VoidCallback? onEdit,
    required RxInt resendTimer,
    required RxBool isLoading,
    int otpLength = 6,
    String title = 'Enter verification code',
    String subtitle = 'Care Life Touch will contact you for your OTP.',
    bool showResendButton = true,
    bool showIdentifier = false,
  }) {
    return Get.dialog(
      OTPVerificationDialog(
        identifier: identifier,
        onVerify: onVerify,
        onResend: onResend,
        onEdit: onEdit,
        resendTimer: resendTimer,
        isLoading: isLoading,
        otpLength: otpLength,
        title: title,
        subtitle: subtitle,
        showResendButton: showResendButton,
        showIdentifier: showIdentifier,
      ),
      barrierDismissible: false,
    );
  }
}
