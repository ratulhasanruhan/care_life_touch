import 'package:get/get.dart';
import '../controllers/shell_controller.dart';

/// Shell Binding - Initializes controllers for shell/main view
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ShellController(), permanent: true);
  }
}

