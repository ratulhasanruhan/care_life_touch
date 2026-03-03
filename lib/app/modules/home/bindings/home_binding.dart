import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Home Binding - Dependency injection for Home module
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
