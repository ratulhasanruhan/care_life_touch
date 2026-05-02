import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../global_widgets/add_to_cart_modal.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../../../routes/app_pages.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/models/product_model.dart';
import '../../home/views/widgets/product_card.dart';
import '../../products/models/products_query.dart';
import '../../products/views/widgets/offer_product_tile.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'Product Details',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Main Content
          ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              _buildImageCarousel(),
              _buildProductInfo(),
              _buildProductDetails(),
              const Divider(height: 1, color: Color(0xFFE8EAE8)),
              _buildMedicineOverview(),
              _buildAlternativeProducts(),
              _buildMoreFromBrand(),
              _buildRelatedProducts(),
            ],
          ),

          // Bottom Add to Cart Bar
          Positioned(left: 20, right: 20, bottom: 20, child: _buildBottomBar()),
        ],
      ),
    );
  }

  /// Image carousel section
  Widget _buildImageCarousel() {
    return Container(
      height: 434,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 434,
              viewportFraction: 1.0,
              enableInfiniteScroll: controller.images.length > 1,
              onPageChanged: (index, reason) {
                controller.currentImageIndex.value = index;
              },
            ),
            items: controller.images.map((imagePath) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 61.5,
                ),
                child: _buildProductImage(imagePath),
              );
            }).toList(),
          ),

          // Page Indicator
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            child: Center(
              child: Obx(
                () => AnimatedSmoothIndicator(
                  activeIndex: controller.currentImageIndex.value,
                  count: controller.images.length,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 5,
                    dotWidth: 5,
                    expansionFactor: 4,
                    spacing: 4,
                    activeDotColor: Color(0xFF064E36),
                    dotColor: Color(0xFFDDDDDD),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Product info section (brand, name, price, rating)
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand
              Expanded(
                child: Text(
                  controller.product.brand,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xB301060F),
                  ),
                ),
              ),

              // Rating with arrow
              Row(
                children: [
                  Obx(
                    () => IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: controller.isWishlistBusy.value
                          ? null
                          : controller.toggleWishlist,
                      icon: Icon(
                        controller.isWishlisted.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: controller.isWishlisted.value
                            ? const Color(0xFFE53935)
                            : const Color(0xB301060F),
                        size: 20,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed(
                        Routes.PRODUCT_REVIEWS,
                        arguments: {
                          'productId': controller.product.id,
                          'productName': controller.product.name,
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFF1B71B),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              controller.product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF01060F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Color(0xB301060F),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Product Name and Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF01060F),
                      ),
                    ),
                    if (controller.product.categoryName.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${controller.product.categoryName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xB301060F),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Price and MOQ
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildHeaderPriceText(),
                  const SizedBox(height: 2),
                  Text(
                    controller.product.moqDisplay,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB301060F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Product details section
  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medicine Info:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Text(
              controller.isDescriptionExpanded.value
                  ? controller.fullDescription
                  : controller.truncatedDescription,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color(0xB301060F),
              ),
            ),
          ),
          if (controller.fullDescription.length > 100)
            TextButton(
              onPressed: controller.toggleDescription,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Obx(
                () => Text(
                  controller.isDescriptionExpanded.value
                      ? 'Read less'
                      : 'Read more',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF064E36),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Medicine overview accordion
  Widget _buildMedicineOverview() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to medicine overview screen
            Get.toNamed(
              Routes.MEDICINE_OVERVIEW,
              arguments: controller.product,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 24,
                  color: Color(0xFF064E36),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Medicine Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 18,
                  color: Color(0xFF01060F),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Alternative products section
  Widget _buildAlternativeProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alternative Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isRelatedLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF064E36)),
                ),
              );
            }

            if (controller.alternativeProducts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'No alternative products found right now.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xB301060F),
                  ),
                ),
              );
            }

            return Column(
              children: controller.alternativeProducts
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OfferProductTile(
                        product: product,
                        onTap: () => _openProductDetails(product),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  /// More from brand section
  Widget _buildMoreFromBrand() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'More From ${controller.product.brand}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF01060F),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final brandKeyword =
                      (controller.product.brandId ?? '').trim().isNotEmpty
                      ? controller.product.brandId!
                      : controller.product.brand;

                  Get.toNamed(
                    Routes.PRODUCTS,
                    arguments: ProductsQuery(
                      type: ProductListingType.brand,
                      title: controller.product.brand,
                      keyword: brandKeyword,
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF064E36),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => ProductCardsTwoColumn(
              products: List<ProductModel>.from(controller.brandProducts),
            ),
          ),
        ],
      ),
    );
  }

  /// Related products section (shown at bottom)
  Widget _buildRelatedProducts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Related Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isRelatedLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF064E36)),
                ),
              );
            }

            if (controller.relatedProducts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'No related products found right now.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xB301060F),
                  ),
                ),
              );
            }

            return Column(
              children: controller.relatedProducts
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OfferProductTile(
                        product: product,
                        onTap: () => _openProductDetails(product),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  /// Bottom add to cart bar
  Widget _buildBottomBar() {
    final cartController = Get.find<CartController>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1C33).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Obx(() {
        final isInCart = cartController.isInCart(controller.product.id);
        final quantity = cartController.getQuantity(controller.product.id);

        return Row(
          children: [
            // Total Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB301060F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildBottomPriceText(isInCart, quantity),
                ],
              ),
            ),

            // Add to Cart Button
            SizedBox(
              width: 140,
              child: CustomButton(
                text: isInCart ? 'In Cart ($quantity)' : 'Add to Cart',
                variant: ButtonVariant.primary,
                size: ButtonSize.medium,
                fullWidth: true,
                onPressed: () {
                  if (isInCart) {
                    Get.toNamed(Routes.CART);
                  } else {
                    // Show modal to select quantity before adding
                    AddToCartModal.show(controller.product);
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported,
          color: Color(0xFFE8EAE8),
          size: 42,
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.image_not_supported,
        color: Color(0xFFE8EAE8),
        size: 42,
      ),
    );
  }

  Widget _buildHeaderPriceText() {
    final product = controller.product;
    final hasCompare = product.maxPrice != null && product.maxPrice! > product.price;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '৳${_money(product.price)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF064E36),
          ),
        ),
        if (hasCompare) ...[
          const SizedBox(width: 6),
          Text(
            '৳${_money(product.maxPrice!)}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8D949D),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomPriceText(bool isInCart, int quantity) {
    final product = controller.product;
    final current = isInCart ? product.price * quantity : product.price;
    final compare = product.maxPrice;
    final hasCompare = compare != null && compare > product.price;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '৳${_money(current)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF064E36),
          ),
        ),
        if (hasCompare) ...[
          const SizedBox(width: 6),
          Text(
            '৳${_money(isInCart ? compare * quantity : compare)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8D949D),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  String _money(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  void _openProductDetails(ProductModel product) {
    if (Get.isRegistered<ProductDetailsController>()) {
      Get.delete<ProductDetailsController>(force: true);
    }

    Get.toNamed(
      Routes.PRODUCT_DETAILS,
      arguments: product,
      preventDuplicates: false,
    );
  }
}
