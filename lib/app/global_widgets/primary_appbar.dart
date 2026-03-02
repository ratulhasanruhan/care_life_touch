import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/app_colors.dart';

/// Primary AppBar widget - used throughout the app
class PrimaryAppBar extends AppBar {
  PrimaryAppBar({
    super.key,
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) : super(
    title: Text(title),
    backgroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
    leading: GestureDetector(
      onTap: onBackPressed ?? () => Get.back(),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Color(0xFF43505C),
          size: 20,
        ),
      ),
    ),
    actions: actions,
    titleTextStyle: const TextStyle(
      fontFamily: 'DM Sans',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Color(0xFF01060F),
      letterSpacing: -0.02,
    ),
  );
}

