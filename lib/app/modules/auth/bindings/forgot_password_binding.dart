import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

/// Forgot Password Binding - Dependency injection for forgot password flow
class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}
