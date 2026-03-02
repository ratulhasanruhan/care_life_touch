import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Auth Binding - Injects dependencies for authentication
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

