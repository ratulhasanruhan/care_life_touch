import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

/// Cart Binding - Dependency injection for cart module
class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}

