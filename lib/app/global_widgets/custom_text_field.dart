import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/values/app_colors.dart';

/// Custom reusable text field widget matching Figma design
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool isRTL; // For Arabic support

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.initialValue,
    this.focusNode,
    this.textInputAction,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (labelText != null)
            Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              labelText!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
          ),

        // Input Field
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: Color(0xFFA2A8AF),
            ),
            prefixIcon: isRTL ? null : prefixIcon,
            suffixIcon: isRTL ? prefixIcon : suffixIcon,
            filled: true,
            fillColor: AppColors.white,

            // Default border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: const BorderSide(color: AppColors.inner, width: 1),
            ),

            // Enabled border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: const BorderSide(color: AppColors.inner, width: 1),
            ),

            // Focused border (Active state)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: const BorderSide(color: AppColors.primary500, width: 1),
            ),

            // Error border
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),

            // Focused error border
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: const BorderSide(color: AppColors.primary500, width: 1),
              // Shadow for typing state with error
            ),

            contentPadding: const EdgeInsets.all(16),

            // Remove helper text padding if not needed
            helperText: helperText,
            helperStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.error,
            ),

            errorText: errorText,
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.error,
            ),
            errorMaxLines: 2,
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
        ),

        // Caption/Helper text (if not using built-in)
        if (helperText != null && helperText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              helperText!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: AppColors.error,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
          ),
      ],
    );
  }
}

