import 'package:flutter/material.dart';
import '../core/values/app_colors.dart';

/// Button variants matching Figma design
enum ButtonVariant { primary, secondary, tertiary }

/// Button sizes matching Figma design
enum ButtonSize { small, medium, large, xlarge }

/// Custom button widget matching Figma design system
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool fullWidth;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    // Get size properties
    final sizeProps = _getSizeProperties();

    // Get color properties based on variant and state
    final colorProps = _getColorProperties(isDisabled);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: sizeProps.height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: colorProps.backgroundColor,
              foregroundColor: colorProps.foregroundColor,
              disabledBackgroundColor: colorProps.disabledBackgroundColor,
              disabledForegroundColor: colorProps.disabledForegroundColor,
              side: colorProps.borderSide,
              elevation: 0,
              padding: sizeProps.padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sizeProps.borderRadius),
              ),
            ).copyWith(
              // Custom colors for hover/pressed states
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return colorProps.disabledBackgroundColor;
                }
                if (states.contains(WidgetState.pressed)) {
                  return colorProps.pressedBackgroundColor;
                }
                if (states.contains(WidgetState.hovered)) {
                  return colorProps.hoverBackgroundColor;
                }
                return colorProps.backgroundColor;
              }),
            ),
        child: isLoading
            ? SizedBox(
                width: sizeProps.iconSize,
                height: sizeProps.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorProps.foregroundColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    SizedBox(
                      width: sizeProps.iconSize,
                      height: sizeProps.iconSize,
                      child: prefixIcon,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: sizeProps.fontSize,
                      fontWeight: FontWeight.w500,
                      height: sizeProps.lineHeight / sizeProps.fontSize,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: sizeProps.iconSize,
                      height: sizeProps.iconSize,
                      child: suffixIcon,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  _SizeProperties _getSizeProperties() {
    switch (size) {
      case ButtonSize.xlarge:
        return _SizeProperties(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          fontSize: 18,
          lineHeight: 26,
          iconSize: 24,
          borderRadius: 8,
        );
      case ButtonSize.large:
        return _SizeProperties(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          fontSize: 16,
          lineHeight: 24,
          iconSize: 20,
          borderRadius: 8,
        );
      case ButtonSize.medium:
        return _SizeProperties(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          fontSize: 14,
          lineHeight: 20,
          iconSize: 18,
          borderRadius: 4,
        );
      case ButtonSize.small:
        return _SizeProperties(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          fontSize: 12,
          lineHeight: 18,
          iconSize: 16,
          borderRadius: 2,
        );
    }
  }

  _ColorProperties _getColorProperties(bool isDisabled) {
    if (isDisabled) {
      // Disabled state for all variants
      switch (variant) {
        case ButtonVariant.primary:
          return _ColorProperties(
            backgroundColor: AppColors.primaryDisabled,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primaryDisabled,
            disabledForegroundColor: AppColors.white,
          );
        case ButtonVariant.secondary:
          return _ColorProperties(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryDisabled,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: AppColors.primaryDisabled,
            borderSide: BorderSide(color: AppColors.primaryDisabled, width: 1),
          );
        case ButtonVariant.tertiary:
          return _ColorProperties(
            backgroundColor: AppColors.primaryDisabled,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primaryDisabled,
            disabledForegroundColor: AppColors.white,
          );
      }
    }

    // Active states
    switch (variant) {
      case ButtonVariant.primary:
        return _ColorProperties(
          backgroundColor: AppColors.primaryDefault, // #064E36
          foregroundColor: AppColors.white,
          hoverBackgroundColor: AppColors.primaryHover, // #022C1E
          pressedBackgroundColor: AppColors.primaryPressed, // #022C1E
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: AppColors.white,
        );

      case ButtonVariant.secondary:
        return _ColorProperties(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          hoverBackgroundColor: AppColors.secondary200, // #5A5B61
          pressedBackgroundColor: AppColors.secondary300, // #404145
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.primaryDisabled,
          borderSide: BorderSide(color: AppColors.secondary100, width: 1),
        );

      case ButtonVariant.tertiary:
        return _ColorProperties(
          backgroundColor: AppColors.inner, // #E8EAEB
          foregroundColor: AppColors.textSecondary, // #43505C
          hoverBackgroundColor: AppColors.errorLight, // #FFF1F1
          pressedBackgroundColor: AppColors.errorLight,
          disabledBackgroundColor: AppColors.primaryDisabled,
          disabledForegroundColor: AppColors.white,
        );
    }
  }
}

class _SizeProperties {
  final double height;
  final EdgeInsets padding;
  final double fontSize;
  final double lineHeight;
  final double iconSize;
  final double borderRadius;

  _SizeProperties({
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.lineHeight,
    required this.iconSize,
    required this.borderRadius,
  });
}

class _ColorProperties {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? hoverBackgroundColor;
  final Color? pressedBackgroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final BorderSide? borderSide;

  _ColorProperties({
    this.backgroundColor,
    this.foregroundColor,
    this.hoverBackgroundColor,
    this.pressedBackgroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderSide,
  });
}
