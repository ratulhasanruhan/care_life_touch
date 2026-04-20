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
      onTap:
          onTap ??
          () {
            Get.toNamed('/product-details', arguments: product);
          },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 165;
          final isRoomy = constraints.maxWidth > 210;
          final imageHeight = isCompact
              ? 116.0
              : isRoomy
                  ? 148.0
                  : 136.0;
          final contentPadding = isCompact ? 6.0 : 8.0;
          final titleFontSize = isCompact ? 11.0 : 12.0;

          return Container(
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
                _buildProductImage(imageHeight: imageHeight, isCompact: isCompact),

                // Product Details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand and Rating
                        _buildBrandAndRating(isCompact: isCompact),

                        SizedBox(height: isCompact ? 1 : 2),

                        // Product Name
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF191930),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        // Price and Add to Bag Button
                        Obx(() => _buildPriceAndButton(cartController, isCompact: isCompact)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build product image section with offer badge
  Widget _buildProductImage({required double imageHeight, required bool isCompact}) {
    return SizedBox(
      height: imageHeight,
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
                padding: EdgeInsets.all(isCompact ? 4 : 6),
                child: product.hasRemoteImage
                    ? Image.network(
                        product.imagePath,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            size: isCompact ? 36 : 48,
                            color: const Color(0xFFE8EAE8),
                          );
                        },
                      )
                    : Image.asset(
                        product.imagePath,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            size: isCompact ? 36 : 48,
                            color: const Color(0xFFE8EAE8),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6 : 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.offerLabel ?? 'SALE',
                    style: TextStyle(
                      fontSize: isCompact ? 9 : 10,
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
  Widget _buildBrandAndRating({required bool isCompact}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.brand,
            style: TextStyle(
              fontSize: isCompact ? 9 : 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xB301060F),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            Icon(Icons.star, color: const Color(0xFFF1B71B), size: isCompact ? 10 : 12),
            SizedBox(width: isCompact ? 1 : 2),
            Text(
              product.rating.toString(),
              style: TextStyle(
                fontSize: isCompact ? 9 : 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF01060F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build price and add to cart button
  Widget _buildPriceAndButton(CartController cartController, {required bool isCompact}) {
    final quantity = cartController.getQuantity(product.id);
    final isInCart = quantity > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Price and MOQ
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceText(isCompact: isCompact),
              Text(
                product.moqDisplay,
                style: TextStyle(
                  fontSize: isCompact ? 7 : 8,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xB301060F),
                ),
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 4),

        // Add to Bag / Quantity Button
        Flexible(
          child: Align(
            alignment: Alignment.bottomRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: isInCart
                  ? _buildQuantityControls(cartController, quantity, isCompact: isCompact)
                  : _buildAddToCartButton(cartController, isCompact: isCompact),
            ),
          ),
        ),
      ],
    );
  }

  /// Build add to cart button
  Widget _buildAddToCartButton(CartController cartController, {required bool isCompact}) {
    return GestureDetector(
      onTap: () async {
        // Add to cart without showing snackbar - just update state
        await cartController.addToCart(product, quantity: 1);
      },
      child: Container(
        height: isCompact ? 20 : 22,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 6),
        decoration: BoxDecoration(
          color: const Color(0xFF064E36),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add to Bag',
              style: TextStyle(
                fontSize: isCompact ? 7 : 8,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(width: isCompact ? 2 : 4),
            Icon(Icons.shopping_bag_outlined, color: Colors.white, size: isCompact ? 9 : 10),
          ],
        ),
      ),
    );
  }

  /// Build quantity controls
  Widget _buildQuantityControls(CartController cartController, int quantity, {required bool isCompact}) {
    return Container(
      height: isCompact ? 20 : 22,
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
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 6),
              child: Icon(Icons.remove, color: Colors.white, size: isCompact ? 10 : 12),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 6),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: isCompact ? 9 : 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => cartController.increaseQuantity(product.id),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 6),
              child: Icon(Icons.add, color: Colors.white, size: isCompact ? 10 : 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceText({required bool isCompact}) {
    final hasCompare =
        product.maxPrice != null && product.maxPrice! > product.price;

    return Row(
      children: [
        Text(
          '৳${_money(product.price)}',
          style: TextStyle(
            fontSize: isCompact ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF064E36),
          ),
        ),
        if (hasCompare) ...[
          SizedBox(width: isCompact ? 2 : 4),
          Flexible(
            child: Text(
              '৳${_money(product.maxPrice!)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isCompact ? 9 : 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8D949D),
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _money(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }
}
