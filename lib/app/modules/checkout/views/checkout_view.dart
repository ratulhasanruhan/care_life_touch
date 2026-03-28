import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'Check Out',
        backgroundColor: const Color(0xFFFFFCFC),
      ),
      body: Obx(() {
        if (controller.cartController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.cartController.cartItems.isEmpty) {
          return _buildEmptyCheckout();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Shipping Address'),
              const SizedBox(height: 8),
              _buildAddressSection(),
              const SizedBox(height: 20),
              _buildSectionTitle('Product Details'),
              const SizedBox(height: 8),
              ...controller.cartController.cartItems
                  .map((item) => _buildProductItem(item)),
              const SizedBox(height: 20),
              _buildSectionTitle('Payment Details'),
              const SizedBox(height: 8),
              _buildPaymentCard(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cartController.cartItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8EAE8)),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F1C33).withValues(alpha: 0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF01060F).withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _money(controller.totalPayable),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    text: 'Confirm',
                    size: ButtonSize.medium,
                    fullWidth: true,
                    isLoading: controller.isPlacingOrder.value,
                    onPressed: controller.isPlacingOrder.value
                        ? null
                        : controller.placeOrder,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.56,
        color: Color(0xFF01060F),
      ),
    );
  }

  Widget _buildAddressSection() {
    if (controller.isLoadingAddresses.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (controller.addressError.value.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8EAE8)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              controller.addressError.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: controller.loadAddresses,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (controller.shippingAddress.value.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8EAE8)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              controller.shippingAddress.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color(0xFF01060F),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showAddressSelectionDialog,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE8EAE8)),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
            label: Text(
              controller.shippingAddress.value.isEmpty
                  ? 'Select Address'
                  : 'Change Address',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.toNamed('/addresses/add'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF064E36)),
              backgroundColor: const Color(0xFFECFDF7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            icon: const Icon(Icons.location_on, size: 18, color: Color(0xFF064E36)),
            label: const Text(
              'Add New Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
                color: Color(0xFF064E36),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: item.product.hasRemoteImage
                  ? Image.network(
                      item.product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        color: Color(0xFFE8EAE8),
                      ),
                    )
                  : Image.asset(
                      item.product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
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
                  item.product.brand,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF01060F).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: Color(0xFF191930),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _money(item.product.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Quantity: ${item.quantity} Box',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF01060F).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildPaymentRow(
            'Total Product:',
            '${controller.totalProductCount} Box',
            valueColor: const Color(0xFF01060F),
          ),
          const SizedBox(height: 8),
          _buildPaymentRow('Total Price:', _money(controller.totalPrice), valueColor: AppColors.primary),
          const SizedBox(height: 8),
          _buildPaymentRow('Discount:', _money(controller.discount), valueColor: const Color(0xFF01060F)),
          const SizedBox(height: 8),
          _buildPaymentRow(
            'Delivery Fee:',
            controller.deliveryFee == 0 ? 'FREE' : _money(controller.deliveryFee),
            valueColor: controller.deliveryFee == 0 ? AppColors.primary : const Color(0xFF01060F),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE8EAE8)),
          const SizedBox(height: 10),
          _buildPaymentRow(
            'Total Payable',
            _money(controller.totalPayable),
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Color(0xFF01060F),
            ),
            valueStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String title,
    String value, {
    Color? valueColor,
    TextStyle? titleStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: const Color(0xFF01060F).withValues(alpha: 0.7),
              ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.43,
                color: valueColor ?? const Color(0xFF01060F),
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyCheckout() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Color(0xFFA2A8AF),
          ),
          SizedBox(height: 12),
          Text(
            'No products to checkout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF01060F),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSelectionDialog() {
    controller.syncSelectedAddressFromCurrent();

    Get.bottomSheet<void>(
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 47,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Column(
                children: List.generate(
                  controller.savedAddresses.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == controller.savedAddresses.length - 1
                          ? 0
                          : 12,
                    ),
                    child: _buildAddressOptionCard(index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Confirm Selection',
              onPressed: controller.confirmSelectedAddress,
              fullWidth: true,
              size: ButtonSize.medium,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildAddressOptionCard(int index) {
    final address = controller.savedAddresses[index];
    final isSelected = controller.selectedAddressIndex.value == index;

    return InkWell(
      onTap: () => controller.selectAddress(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8EAE8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.isDefault ? 'Default Address' : 'Saved Address',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: Color(0xFFA2A8AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.addressType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: Color(0xFF01060F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.details,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: const Color(0xFF01060F).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EAE8)),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _money(double amount) => '৳${amount.toStringAsFixed(0)}';
}



