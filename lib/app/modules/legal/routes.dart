import 'package:care_life_touch/app/modules/legal/views/about_view.dart';
import 'package:care_life_touch/app/modules/legal/views/privacy_view.dart';
import 'package:care_life_touch/app/modules/legal/views/terms_view.dart';
import 'package:get/get.dart';
import 'controllers/legal_controller.dart';

class LegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LegalController>(
      () => LegalController(),
    );
  }
}

class LegalRoutes {
  static const String terms = '/legal/terms';
  static const String privacy = '/legal/privacy';
  static const String about = '/legal/about';

  static List<GetPage> pages = [
    GetPage(
      name: terms,
      page: () => const TermsView(),
      binding: LegalBinding(),
    ),
    GetPage(
      name: privacy,
      page: () => const PrivacyView(),
      binding: LegalBinding(),
    ),
    GetPage(
      name: about,
      page: () => const AboutView(),
      binding: LegalBinding(),
    ),
  ];
}

