import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';

/// Global Info Modal Widget
///
/// A reusable modal for displaying success messages and info dialogs
/// that appears at the bottom of the screen with a dialog-style overflow effect.
///
/// Features:
/// - Bottom-positioned modal with dialog styling
/// - Customizable title and description
/// - Support for custom illustrations/icons
/// - Call-to-action button
/// - Smooth animations
/// - Optional image asset support
///
/// Example Usage:
/// ```dart
/// InfoModal.show(
///   title: 'Password Updated!',
///   description: 'Your password has been set up successfully.',
///   buttonText: 'Confirm',
///   onPressed: () => Get.back(),
///   imagePath: 'assets/images/success_illustration.png',
/// );
///
/// // Or with custom widget
/// InfoModal.show(
///   title: 'Success',
///   description: 'Operation completed successfully',
///   buttonText: 'Done',
///   onPressed: () => Get.back(),
///   icon: Icons.check_circle,
///   iconColor: AppColors.primary,
/// );
/// ```
class InfoModal extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? buttonColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? buttonStyle;

  const InfoModal({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.imagePath,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.buttonColor,
    this.titleStyle,
    this.descriptionStyle,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.bottomCenter,
      insetAnimationDuration: const Duration(milliseconds: 300),
      child: Container(
        width: 358,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // Illustration or Icon
            if (imagePath != null) ...[
              SizedBox(
                width: 157,
                height: 183,
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.contain,
                ),
              ),
            ] else if (icon != null) ...[
              SizedBox(
                width: 157,
                height: 157,
                child: Center(
                  child: Icon(
                    icon,
                    size: 120,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 80),
            ],

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: titleStyle ?? const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: Color(0xFF01060F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: descriptionStyle ?? const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: Color(0xFF191930),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor ?? const Color(0xFF064E36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: buttonStyle ?? const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Static method to show the modal
  static Future<void> show({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    String? imagePath,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    Color? buttonColor,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    TextStyle? buttonStyle,
    bool barrierDismissible = false,
  }) {
    return Get.dialog(
      InfoModal(
        title: title,
        description: description,
        buttonText: buttonText,
        onPressed: onPressed,
        imagePath: imagePath,
        icon: icon,
        iconColor: iconColor,
        backgroundColor: backgroundColor,
        buttonColor: buttonColor,
        titleStyle: titleStyle,
        descriptionStyle: descriptionStyle,
        buttonStyle: buttonStyle,
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}

