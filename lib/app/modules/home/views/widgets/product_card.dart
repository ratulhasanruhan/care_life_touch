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
          final isUltraCompact = constraints.maxWidth < 150;
          final isCompact = constraints.maxWidth < 170;
          final imageHeight = (constraints.maxWidth * 0.74).clamp(108.0, 148.0);
          final contentPadding = isCompact ? 6.0 : 8.0;
          // Match primary price text size (see _buildPriceText).
          final headlineFontSize = isCompact ? 15.0 : 16.0;
          final genericFontSize = isCompact ? 11.0 : 12.0;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8EAE8)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProductImage(
                    imageHeight: imageHeight,
                    isCompact: isCompact,
                  ),
                  Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandAndRating(
                          isCompact: isCompact,
                          headlineFontSize: headlineFontSize,
                        ),
                        SizedBox(height: isCompact ? 1 : 2),
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: headlineFontSize,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF191930),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.genericStrengthSubtitle != null) ...[
                          SizedBox(height: isCompact ? 2 : 3),
                          Text(
                            product.genericStrengthSubtitle!,
                            style: TextStyle(
                              fontSize: genericFontSize,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xB301060F),
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (product.cardShortDescription != null) ...[
                          SizedBox(height: isCompact ? 2 : 3),
                          Text(
                            product.cardShortDescription!,
                            style: TextStyle(
                              fontSize: genericFontSize,
                              fontWeight: FontWeight.w400,
                              color: const Color(0x8C01060F),
                              height: 1.35,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: isCompact ? 6 : 8),
                        Obx(
                          () => _buildPriceAndButton(
                            cartController,
                            isCompact: isCompact,
                            isUltraCompact: isUltraCompact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build product image section with offer badge
  Widget _buildProductImage({
    required double imageHeight,
    required bool isCompact,
  }) {
    final discountLabel = _resolveDiscountLabel();

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
            if (discountLabel != null)
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
                    discountLabel,
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
  Widget _buildBrandAndRating({
    required bool isCompact,
    required double headlineFontSize,
  }) {
    // Rating visually prominent — larger than generic/subtitle text.
    final ratingStarSize = isCompact ? 18.0 : 20.0;
    final ratingTextSize = isCompact ? 15.0 : 16.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.brand,
            style: TextStyle(
              fontSize: headlineFontSize,
              fontWeight: FontWeight.w400,
              color: const Color(0xB301060F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFF1B71B),
                size: ratingStarSize,
              ),
              SizedBox(width: isCompact ? 2 : 3),
              Text(
                product.rating.toString(),
                style: TextStyle(
                  fontSize: ratingTextSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF01060F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build price and add to cart button
  Widget _buildPriceAndButton(
    CartController cartController, {
    required bool isCompact,
    required bool isUltraCompact,
  }) {
    final quantity = cartController.getQuantity(product.id);
    final isInCart = quantity > 0;
    final action = isInCart
        ? _buildQuantityControls(
            cartController,
            quantity,
            isCompact: isCompact,
            isUltraCompact: isUltraCompact,
          )
        : _buildAddToCartButton(
            cartController,
            isCompact: isCompact,
            isUltraCompact: isUltraCompact,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceText(isCompact: isCompact),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                product.moqDisplay,
                style: TextStyle(
                  fontSize: isUltraCompact ? 9 : (isCompact ? 10 : 11),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xB301060F),
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isUltraCompact ? 96 : (isCompact ? 112 : 128),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: action,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Add to cart — original compact size; [InkWell] for splash / reliable tap handling.
  Widget _buildAddToCartButton(
    CartController cartController, {
    required bool isCompact,
    required bool isUltraCompact,
  }) {
    return Material(
      color: const Color(0xFF064E36),
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await cartController.addToCart(product, quantity: 1);
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isUltraCompact ? 3 : (isCompact ? 4 : 6),
            vertical: isUltraCompact ? 2 : (isCompact ? 3 : 4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add to Bag',
                style: TextStyle(
                  fontSize: isUltraCompact ? 10 : (isCompact ? 11 : 12),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isUltraCompact ? 1.5 : (isCompact ? 2 : 4)),
              Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: isUltraCompact ? 10 : (isCompact ? 11 : 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build quantity controls
  Widget _buildQuantityControls(
    CartController cartController,
    int quantity, {
    required bool isCompact,
    required bool isUltraCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isUltraCompact ? 2 : (isCompact ? 3 : 4),
      ),
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
              padding: EdgeInsets.symmetric(
                horizontal: isUltraCompact ? 3 : (isCompact ? 4 : 6),
              ),
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: isUltraCompact ? 10 : (isCompact ? 11 : 12),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isUltraCompact ? 3 : (isCompact ? 4 : 6),
            ),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: isUltraCompact ? 10 : (isCompact ? 11 : 12),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => cartController.increaseQuantity(product.id),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isUltraCompact ? 3 : (isCompact ? 4 : 6),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: isUltraCompact ? 10 : (isCompact ? 11 : 12),
              ),
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
            fontSize: isCompact ? 15 : 16,
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
                 fontSize: isCompact ? 14 : 15,
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

  String? _resolveDiscountLabel() {
    final label = product.offerLabel?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }

    final comparePrice = product.maxPrice;
    if (comparePrice != null &&
        comparePrice > 0 &&
        comparePrice > product.price) {
      final discountPercent =
          (((comparePrice - product.price) / comparePrice) * 100).round();
      if (discountPercent > 0) {
        return '$discountPercent% OFF';
      }
    }

    return null;
  }
}

/// Two-column layout for [ProductCard]s — same card widget; row height follows the taller item.
class ProductCardsTwoColumn extends StatelessWidget {
  const ProductCardsTwoColumn({
    super.key,
    required this.products,
    this.spacing = 12,
    this.padding = EdgeInsets.zero,
  });

  final List<ProductModel> products;
  final double spacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final rows = (products.length + 1) ~/ 2;
    final halfGap = spacing / 2;

    return Padding(
      padding: padding,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
        },
        children: [
          for (var row = 0; row < rows; row++)
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: halfGap,
                    bottom: row < rows - 1 ? spacing : 0,
                  ),
                  child: ProductCard(product: products[row * 2]),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: halfGap,
                    bottom: row < rows - 1 ? spacing : 0,
                  ),
                  child: row * 2 + 1 < products.length
                      ? ProductCard(product: products[row * 2 + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
