import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';

class TermsRichText extends StatelessWidget {
  final VoidCallback? onTermsTapped;
  final VoidCallback? onPrivacyTapped;
  final TextAlign textAlign;
  final double fontSize;
  final double height;
  final FontWeight fontWeight;
  final Color textColor;
  final Color linkColor;

  const TermsRichText({
    super.key,
    this.onTermsTapped,
    this.onPrivacyTapped,
    this.textAlign = TextAlign.center,
    this.fontSize = 12,
    this.height = 1.5,
    this.fontWeight = FontWeight.w400,
    this.textColor = AppColors.textSecondary,
    this.linkColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          height: height,
          fontFamily: 'DM Sans',
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: linkColor,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsTapped,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: linkColor,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTapped,
          ),
        ],
      ),
    );
  }
}
