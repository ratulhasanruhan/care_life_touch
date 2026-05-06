import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cart_controller.dart';

/// Cart View - Shopping cart screen
class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        title: const Text(
          'My Bag',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF01060F),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF064E36)),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.cartItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.loadCart(showLoader: false),
            color: const Color(0xFF064E36),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: Get.height * 0.62,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 56,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF727379),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: controller.loadCart,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.cartItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.loadCart(showLoader: false),
            color: const Color(0xFF064E36),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: Get.height * 0.62, child: _buildEmptyCart()),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadCart(showLoader: false),
                color: const Color(0xFF064E36),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return _buildCartItem(item);
                  },
                ),
              ),
            ),

            // Bottom Summary
            _buildBottomSummary(),
          ],
        );
      }),
    );
  }

  /// Build empty cart widget
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add products to your cart to see them here',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF727379),
            ),
          ),
        ],
      ),
    );
  }

  static const _brandGreen = Color(0xFF064E36);
  static const _titleInk = Color(0xFF191930);

  /// Cart line — matches My Bag tile spec (no checkbox): photo 80², brand/name/price + qty row.
  Widget _buildCartItem(CartItem item) {
    final resolvedProductId = item.product.id.isNotEmpty
        ? item.product.id
        : item.productId;
    final productName = item.product.name.trim().isEmpty
        ? 'Product'
        : item.product.name;
    final brandName = item.product.brand.trim();
    final priceText = '৳${_money(item.unitPrice)}';
    final hasImage = item.product.imagePath.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            // Match close button inset (Positioned right: 6) so ± aligns with × horizontally.
            padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cartItemImage(item, hasImage),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (brandName.isNotEmpty) ...[
                              Text(
                                brandName,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 18 / 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF01060F).withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 24 / 16,
                                fontWeight: FontWeight.w500,
                                color: _titleInk,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _cartItemPriceRow(item, priceText),
                            ),
                            Obx(
                              () => _CartQtyStepper(
                                quantity: item.quantity,
                                enabled: !controller.isMutating.value,
                                onDecrease: () => controller
                                    .decreaseQuantity(resolvedProductId),
                                onIncrease: () => controller
                                    .increaseQuantity(resolvedProductId),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Remove — top right (red ×)
          Positioned(
            top: 6,
            right: 6,
            child: Obx(
              () => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.isMutating.value
                      ? null
                      : () => controller.removeFromCart(resolvedProductId),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sale price + optional compare (MRP) with strikethrough, same idea as product cards.
  Widget _cartItemPriceRow(CartItem item, String priceText) {
    final compare = item.product.maxPrice;
    final unit = item.unitPrice;
    final showCompare =
        compare != null && compare > unit + 0.0001;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          priceText,
          style: const TextStyle(
            fontSize: 16,
            height: 21 / 16,
            fontWeight: FontWeight.w700,
            color: _brandGreen,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showCompare) ...[
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '৳${_money(compare)}',
              style: const TextStyle(
                fontSize: 15,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                decoration: TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _cartItemImage(CartItem item, bool hasImage) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: item.product.hasRemoteImage
            ? Image.network(
                item.product.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 28,
                    color: Color(0xFFE8EAE8),
                  );
                },
              )
            : hasImage
            ? Image.asset(
                item.product.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 28,
                    color: Color(0xFFE8EAE8),
                  );
                },
              )
            : const Icon(
                Icons.image_not_supported,
                size: 28,
                color: Color(0xFFE8EAE8),
              ),
      ),
    );
  }

  /// Build bottom summary
  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EAE8))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF727379),
                  ),
                ),
                Text(
                  '৳${_money(controller.subtotal)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF01060F),
                  ),
                ),
              ],
            ),

            if (controller.discount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF727379),
                    ),
                  ),
                  Text(
                    '-৳${_money(controller.discount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Delivery Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Fee',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF727379),
                  ),
                ),
                Text(
                  controller.deliveryFee == 0
                      ? 'FREE'
                      : '৳${_money(controller.deliveryFee)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: controller.deliveryFee == 0
                        ? const Color(0xFF064E36)
                        : const Color(0xFF01060F),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF01060F),
                  ),
                ),
                Text(
                  '৳${_money(controller.total)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E36),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isMutating.value
                    ? null
                    : () {
                        Get.toNamed(Routes.CHECKOUT);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  String _money(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }
}

/// [−] [qty] [+] — 24² keys, modest inner inset; sits at row trailing edge.
class _CartQtyStepper extends StatelessWidget {
  const _CartQtyStepper({
    required this.quantity,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  static const _keyBg = Color(0xFFEEEEEE);
  static const _titleInk = Color(0xFF191930);
  static const _keySide = 24.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _greyKey(
            icon: Icons.remove,
            iconColor: Colors.black,
            onTap: enabled ? onDecrease : null,
          ),
          const SizedBox(width: 8),
          Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          _greyKey(
            icon: Icons.add,
            iconColor: _titleInk,
            onTap: enabled ? onIncrease : null,
          ),
        ],
      ),
    );
  }

  Widget _greyKey({
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: _keyBg,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _keySide,
          height: _keySide,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(icon, size: 13, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
