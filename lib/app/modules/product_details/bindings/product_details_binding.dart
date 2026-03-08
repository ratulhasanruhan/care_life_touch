import 'package:get/get.dart';
import '../controllers/product_details_controller.dart';
import '../../home/models/product_model.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    // Get the product from navigation arguments
    final product = Get.arguments as ProductModel?;

    if (product == null) {
      // If no product provided, go back
      Get.back();
      return;
    }

    Get.lazyPut<ProductDetailsController>(
      () => ProductDetailsController(product: product),
    );
  }
}

