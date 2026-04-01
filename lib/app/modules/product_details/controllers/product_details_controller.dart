import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';
import '../controllers/wishlist_controller.dart';
import '../../home/models/product_model.dart';

class ProductDetailsController extends GetxController {
  final ProductModel product;
  final ProductRepository _productRepository;
  final WishlistController _wishlistController;

  ProductDetailsController({
    required this.product,
    ProductRepository? productRepository,
    WishlistController? wishlistController,
  }) : _productRepository = productRepository ?? Get.find<ProductRepository>(),
       _wishlistController =
           wishlistController ?? Get.find<WishlistController>();

  // Observable properties
  final currentImageIndex = 0.obs;
  final isDescriptionExpanded = false.obs;
  final alternativeProducts = <ProductModel>[].obs;
  final relatedProducts = <ProductModel>[].obs;
  final brandProducts = <ProductModel>[].obs;
  final isRelatedLoading = false.obs;
  final isWishlisted = false.obs;
  final isWishlistBusy = false.obs;

  // Product images (carousel)
  List<String> get images =>
      product.imageUrls.isNotEmpty ? product.imageUrls : [product.imagePath];

  // Description management
  String get fullDescription {
    final description = product.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }

    return 'Medicine information is not available for this product right now.';
  }

  String get truncatedDescription {
    if (fullDescription.length <= 100) return fullDescription;
    return '${fullDescription.substring(0, 100)}...';
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _syncWishlistState();
  }

  /// Load alternative, related, and brand products
  Future<void> _loadData() async {
    isRelatedLoading.value = true;
    final slug = product.slug;

    try {
      if (slug != null && slug.isNotEmpty) {
        final related = await _productRepository.getRelatedProducts(slug);
        relatedProducts.assignAll(
          related.where((item) => item.id != product.id).take(3),
        );
      }
    } catch (_) {
      // Fall back to local filtering below when related API fails.
    }

    try {
      final allProducts = await _productRepository.getAllProducts();

      if (alternativeProducts.isEmpty) {
        alternativeProducts.assignAll(
          allProducts
              .where((p) => p.id != product.id && p.brand != product.brand)
              .take(3),
        );
      }

      if (relatedProducts.isEmpty) {
        relatedProducts.assignAll(
          allProducts
              .where(
                (p) =>
                    p.id != product.id &&
                    p.categoryName.trim().isNotEmpty &&
                    p.categoryName == product.categoryName,
              )
              .take(3),
        );
      }

      // Ensure related section includes some same-brand products when available.
      final relatedIds = relatedProducts.map((p) => p.id).toSet();

      if (relatedProducts.length < 3) {
        final sameBrand = allProducts
            .where(
              (p) =>
                  p.id != product.id &&
                  p.brand == product.brand &&
                  !relatedIds.contains(p.id),
            )
            .take(3 - relatedProducts.length)
            .toList();

        if (sameBrand.isNotEmpty) {
          relatedProducts.addAll(sameBrand);
          relatedIds.addAll(sameBrand.map((p) => p.id));
        }
      }

      if (relatedProducts.length < 3) {
        final sameCategory = allProducts
            .where(
              (p) =>
                  p.id != product.id &&
                  p.categoryName.trim().isNotEmpty &&
                  p.categoryName == product.categoryName &&
                  !relatedIds.contains(p.id),
            )
            .take(3 - relatedProducts.length)
            .toList();

        if (sameCategory.isNotEmpty) {
          relatedProducts.addAll(sameCategory);
        }
      }

      brandProducts.assignAll(
        allProducts
            .where((p) => p.id != product.id && p.brand == product.brand)
            .take(4),
      );
    } catch (_) {
      // Keep any related products already loaded from the related endpoint.
      brandProducts.clear();
    } finally {
      isRelatedLoading.value = false;
    }
  }

  /// Toggle description expanded state
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  Future<void> toggleWishlist() async {
    if (isWishlistBusy.value) return;

    final previous = isWishlisted.value;
    isWishlistBusy.value = true;
    isWishlisted.value = !previous;

    try {
      await _wishlistController.toggleWishlist(product.id);
      isWishlisted.value = _wishlistController.isInWishlist(product.id);
    } catch (_) {
      isWishlisted.value = previous;
    } finally {
      isWishlistBusy.value = false;
    }
  }

  Future<void> _syncWishlistState() async {
    try {
      if (_wishlistController.wishlistItems.isEmpty) {
        await _wishlistController.loadWishlist();
      }
      isWishlisted.value = _wishlistController.isInWishlist(product.id);
    } catch (_) {
      isWishlisted.value = false;
    }
  }
}
