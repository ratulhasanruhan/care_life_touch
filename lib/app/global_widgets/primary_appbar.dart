import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Primary AppBar widget - used throughout the app
class PrimaryAppBar extends AppBar {
  PrimaryAppBar({
    super.key,
    required String title,
    VoidCallback? onBackPressed,
    super.actions,
    bool showBackButton = true,
    Color? backgroundColor,
    Color? scrollColor,
  }) : super(
         title: Text(title),
         backgroundColor: backgroundColor ?? const Color(0xFFFFFCFC),
         elevation: 0,
         centerTitle: true,
         automaticallyImplyLeading: true,
         surfaceTintColor: scrollColor ?? const Color(0xFFFFFCFC),
         leading: showBackButton
             ? GestureDetector(
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
               )
             : null,
         titleTextStyle: const TextStyle(
           fontWeight: FontWeight.w600,
           fontSize: 18,
           color: Color(0xFF01060F),
           letterSpacing: -0.02,
         ),
       );
}
