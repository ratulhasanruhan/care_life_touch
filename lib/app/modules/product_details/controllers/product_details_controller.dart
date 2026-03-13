import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';
import '../../home/models/product_model.dart';

class ProductDetailsController extends GetxController {
  final ProductModel product;
  final ProductRepository _productRepository;

  ProductDetailsController({
    required this.product,
    ProductRepository? productRepository,
  }) : _productRepository = productRepository ?? Get.find<ProductRepository>();

  // Observable properties
  final currentImageIndex = 0.obs;
  final isDescriptionExpanded = false.obs;
  final alternativeProducts = <ProductModel>[].obs;
  final brandProducts = <ProductModel>[].obs;

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
  }

  /// Load alternative and brand products
  Future<void> _loadData() async {
    final allProducts = await _productRepository.getAllProducts();

    // Get alternative products (different brands, same type)
    alternativeProducts.value = allProducts
        .where((p) => p.id != product.id && p.brand != product.brand)
        .take(3)
        .toList();

    // Get products from same brand
    brandProducts.value = allProducts
        .where((p) => p.id != product.id && p.brand == product.brand)
        .take(4)
        .toList();
  }

  /// Toggle description expanded state
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
}

