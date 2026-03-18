import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/legal_controller.dart';

class PrivacyView extends GetView<LegalController> {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(title: 'Privacy Policy'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final content = controller.privacyText.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            content.isEmpty
                ? 'Privacy policy is not available right now. Please try again later.'
                : content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        );
      }),
    );
  }
}
