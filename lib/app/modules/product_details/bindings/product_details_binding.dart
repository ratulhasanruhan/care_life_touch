import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../controllers/product_details_controller.dart';
import '../controllers/wishlist_controller.dart';
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

    // Ensure ProductRepository is available
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(() => ProductRepository());
    }
    if (!Get.isRegistered<WishlistRepository>()) {
      Get.lazyPut<WishlistRepository>(() => WishlistRepository());
    }
    if (!Get.isRegistered<WishlistController>()) {
      Get.lazyPut<WishlistController>(() => WishlistController());
    }

    Get.lazyPut<ProductDetailsController>(
      () => ProductDetailsController(product: product),
    );
  }
}

