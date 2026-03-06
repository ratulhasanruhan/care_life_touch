import 'package:get/get.dart';

class LegalController extends GetxController {
  // Terms, Privacy Policy, and About content management

  final isLoading = false.obs;

  void openTermsOfService() {
    Get.toNamed('/legal/terms');
  }

  void openPrivacyPolicy() {
    Get.toNamed('/legal/privacy');
  }

  void openAbout() {
    Get.toNamed('/legal/about');
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
