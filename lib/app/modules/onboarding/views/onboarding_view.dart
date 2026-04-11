import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../legal/routes.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/terms_rich_text.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.pages.isEmpty) {
            return const Center(
              child: Text('No onboarding data available'),
            );
          }

          return Stack(
            children: [
              // PageView
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.updateIndex,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _buildOnboardingPage(page);
                },
              ),

              // Page indicator + Button + Terms (bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicator
                      SmoothPageIndicator(
                        controller: controller.pageController,
                        count: controller.pages.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          spacing: 4,
                          expansionFactor: 3.5,
                          activeDotColor: AppColors.primary,
                          dotColor: AppColors.lightGrey,
                          paintStyle: PaintingStyle.fill,
                        ),
                        onDotClicked: (index) {
                          controller.pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Get Started Button with Arrow
                      CustomButton(
                        text: 'Get Started',
                        fullWidth: true,
                        size: ButtonSize.large,
                        suffixIcon: Icon(
                          Icons.arrow_forward,
                          color: AppColors.white,
                          size: 20,
                        ),
                        onPressed: controller.nextPage,
                      ),

                      const SizedBox(height: 22),

                      // Terms and Privacy Text
                      TermsRichText(
                        onTermsTapped: () => Get.toNamed(LegalRoutes.terms),
                        onPrivacyTapped: () => Get.toNamed(LegalRoutes.privacy),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Build individual onboarding page
  Widget _buildOnboardingPage(dynamic page) {
    return Column(
      children: [
        SizedBox(height: Get.height * 0.2),
        // Image
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _buildPageImage(page.image),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Build page image supporting both asset and network images
  Widget _buildPageImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackImage(imagePath),
      );
    }

    return _buildFallbackImage(imagePath);
  }

  Widget _buildFallbackImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        width: 200,
        height: 200,
        child: Icon(Icons.image_not_supported, size: 80),
      ),
    );
  }
}
