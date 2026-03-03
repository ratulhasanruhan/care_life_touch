import 'package:get/get.dart';
import '../../home/bindings/home_binding.dart';
import '../controllers/shell_controller.dart';

/// Shell Binding - Initializes controllers for shell/main view
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Shell controls the main tabs, so it owns tab-level dependencies.
    HomeBinding().dependencies();
    Get.put(ShellController(), permanent: true);
  }
}
