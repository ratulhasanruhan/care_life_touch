import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Center icon with branding logo or fallback
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Obx(() {
                    // If logo URL is available, use it; otherwise use fallback
                    if (controller.splashLogo.value.isNotEmpty) {
                      return Image.network(
                        controller.splashLogo.value,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return _buildFallbackImage();
                        },
                      );
                    }
                    return _buildFallbackImage();
                  }),
                ),
              ),
            ),

            // Bottom text
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Obx(
                () => Text(
                  controller.splashText.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      'assets/images/splash_icon.png',
      fit: BoxFit.contain,
    );
  }
}
