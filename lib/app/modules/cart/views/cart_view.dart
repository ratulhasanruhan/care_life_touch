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

  /// Build cart item widget
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: item.product.hasRemoteImage
                  ? Image.network(
                      item.product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 32,
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
                          size: 32,
                          color: Color(0xFFE8EAE8),
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Color(0xFFE8EAE8),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF01060F),
                  ),
                ),
                if (brandName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    brandName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF727379),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF064E36),
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: controller.isMutating.value
                          ? null
                          : () =>
                                controller.decreaseQuantity(resolvedProductId),
                      icon: const Icon(Icons.remove, size: 16),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF01060F),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.isMutating.value
                          ? null
                          : () =>
                                controller.increaseQuantity(resolvedProductId),
                      icon: const Icon(Icons.add, size: 16),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: controller.isMutating.value
                    ? null
                    : () => controller.removeFromCart(resolvedProductId),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
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
