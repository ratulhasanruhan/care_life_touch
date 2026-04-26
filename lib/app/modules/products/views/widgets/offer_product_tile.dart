import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../cart/controllers/cart_controller.dart';
import '../../../home/models/product_model.dart';

class OfferProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const OfferProductTile({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return GestureDetector(
      onTap: onTap ?? () {
        Get.toNamed('/product-details', arguments: product);
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8EAE8)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: product.hasRemoteImage
                    ? Image.network(
                        product.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFFE8EAE8),
                        ),
                      )
                    : Image.asset(
                        product.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFFE8EAE8),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF191930),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFF1B71B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF01060F),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Obx(() => _buildBottomRow(cartController)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow(CartController cartController) {
    final isInCart = cartController.isInCart(product.id);
    final quantity = cartController.getQuantity(product.id);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceText(),
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
        if (isInCart && quantity > 0)
          _buildQuantityControls(cartController, quantity)
        else
          _buildAddToCartButton(cartController),
      ],
    );
  }

  Widget _buildAddToCartButton(CartController cartController) {
    return GestureDetector(
      onTap: () async {
        await cartController.addToCart(product, quantity: 1);
      },
      child: Container(
        width: 68,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF064E36),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'Add to Bag',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.remove, color: Colors.white, size: 12),
            ),
          ),
          Text(
            quantity.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => cartController.increaseQuantity(product.id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceText() {
    final hasCompare =
        product.maxPrice != null && product.maxPrice! > product.price;

    return Row(
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
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '৳${_money(product.maxPrice!)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8D949D),
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
