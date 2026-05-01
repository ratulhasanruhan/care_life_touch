import 'package:get/get.dart';
import '../controllers/register_controller.dart';

/// Register Binding - Injects dependencies for registration flow
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}

