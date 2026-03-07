import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductRepository>()) {
      Get.put(ProductRepository(), permanent: true);
    }
  }
}
