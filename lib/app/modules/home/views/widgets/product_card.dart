import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import '../../../cart/controllers/cart_controller.dart';

/// Product Card Widget - Reusable product card component
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return GestureDetector(
      onTap: onTap ?? () {
        Get.toNamed('/product-details', arguments: product);
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8EAE8)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badge
            _buildProductImage(),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand and Rating
                    _buildBrandAndRating(),

                    const SizedBox(height: 2),

                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF191930),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price and Add to Bag Button
                    Obx(() => _buildPriceAndButton(cartController)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build product image section with offer badge
  Widget _buildProductImage() {
    return SizedBox(
      height: 140,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: product.hasRemoteImage
                    ? Image.network(
                        product.imagePath,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Color(0xFFE8EAE8),
                          );
                        },
                      )
                    : Image.asset(
                        product.imagePath,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Color(0xFFE8EAE8),
                          );
                        },
                      ),
              ),
            ),
            if (product.hasOffer)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E36),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.offerLabel ?? 'SALE',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build brand name and rating row
  Widget _buildBrandAndRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.brand,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xB301060F),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFF1B71B), size: 12),
            const SizedBox(width: 2),
            Text(
              product.rating.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF01060F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build price and add to cart button
  Widget _buildPriceAndButton(CartController cartController) {
    final isInCart = cartController.isInCart(product.id);
    final quantity = cartController.getQuantity(product.id);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price and MOQ
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.priceDisplay,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF064E36),
                ),
              ),
              Text(
                product.moqDisplay,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  color: Color(0xB301060F),
                ),
              ),
            ],
          ),
        ),

        // Add to Bag / Quantity Button
        if (isInCart && quantity > 0)
          _buildQuantityControls(cartController, quantity)
        else
          _buildAddToCartButton(cartController),
      ],
    );
  }

  /// Build add to cart button
  Widget _buildAddToCartButton(CartController cartController) {
    return GestureDetector(
      onTap: () => cartController.addToCart(product),
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF064E36),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Add to Bag',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 10),
          ],
        ),
      ),
    );
  }

  /// Build quantity controls
  Widget _buildQuantityControls(CartController cartController, int quantity) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF064E36),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => cartController.decreaseQuantity(product.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: const Icon(Icons.remove, color: Colors.white, size: 12),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => cartController.increaseQuantity(product.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}
