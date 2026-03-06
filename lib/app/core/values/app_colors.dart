import 'package:flutter/material.dart';

/// App Colors from Figma Design System
class AppColors {
  // Primary Color Scale (Green)
  static const primary = Color(0xFF064E36); // 800 - Main primary
  static const primary50 = Color(0xFFECFDF7);
  static const primary100 = Color(0xFFD1FAEC);
  static const primary200 = Color(0xFFA7F3DA);
  static const primary300 = Color(0xFF6EE7BF);
  static const primary400 = Color(0xFF34D39E);
  static const primary500 = Color(0xFF10B981); // Main
  static const primary600 = Color(0xFF059666);
  static const primary700 = Color(0xFF065F42);
  static const primary800 = Color(0xFF064E36); // Main primary
  static const primary900 = Color(0xFF022C1E);

  // Button States (Primary)
  static const primaryDefault = Color(0xFF064E36);
  static const primaryHover = Color(0xFF022C1E);
  static const primaryPressed = Color(0xFF022C1E);
  static const primaryDisabled = Color(0xFFB2B8BD);

  // Neutral/Grey Scale
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const line = Color(0xFFE8EAEB);

  // Shades
  static const shade50 = Color(0xFF01060F);
  static const shade100 = Color(0xFF01060F); // With 70% opacity
  static const shade200 = Color(0xFFA2A8AF);

  // Secondary Colors (Grey for buttons/text)
  static const secondary50 = Color(0xFFFFFFFF);
  static const secondary100 = Color(0xFF727379);
  static const secondary200 = Color(0xFF5A5B61);
  static const secondary300 = Color(0xFF404145);
  static const secondaryDisabled = Color(0xFFB2B8BD);

  // Background & Surface
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const inner = Color(0xFFE8EAE8);
  static const innerDisable = Color(0xFFFAFAFB);

  // Border
  static const border = Color(0xFFDEDEDE);

  // Status Colors - Error (Red)
  static const error = Color(0xFFEF4444); // 500 Main
  static const error50 = Color(0xFFFEF2F2);
  static const error100 = Color(0xFFFEE2E2);
  static const error500 = Color(0xFFEF4444);

  // Status Colors - Success (Green)
  static const success = Color(0xFF22C55E); // 500 Main
  static const success50 = Color(0xFFF0FDF4);
  static const success100 = Color(0xFFDCFCE7);
  static const success500 = Color(0xFF22C55E);

  // Status Colors - Warning (Yellow)
  static const warning = Color(0xFFEAB308); // 500 Main
  static const warning50 = Color(0xFFFEFCE8);
  static const warning100 = Color(0xFFFEF9C3);
  static const warning500 = Color(0xFFEAB308);

  // Status Colors - Info (Blue)
  static const info = Color(0xFF3B82F6); // 500 Main
  static const info50 = Color(0xFFEFF6FF);
  static const info100 = Color(0xFFDBEAFE);
  static const info500 = Color(0xFF3B82F6);

  // Text Colors
  static const textPrimary = Color(0xFF08101F);
  static const textSecondary = Color(0xFF43505C);
  static const textTertiary = Color(0xFF505F79);
  static const textOnPrimary = Color(0xFFFFFFFF); // White text on primary
  static const textDisabled = Color(0xFFB2B8BD);

  // Additional Utility Colors
  static const shadow = Color(0x1A000000); // 10% black
  static const transparent = Color(0x00000000);

  // Error highlight
  static const errorHighlight = Color(0xFFE31B40);
  static const errorLight = Color(0xFFFFF1F1);

  // Backward compatibility aliases
  static const grey = secondary200; // 0xFF5A5B61
  static const lightGrey = line; // 0xFFE8EAEB
}
