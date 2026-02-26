import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Home Binding - Dependency injection for Home module
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize dependencies
    // Get.lazyPut(() => ApiProvider());
    // Get.lazyPut(() => MedicineRepository(Get.find()));

    // Initialize controller
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}

