import 'package:care_life_touch/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../modules/home/models/product_model.dart';
import 'custom_button.dart';

/// Add to Cart Success Modal
class AddToCartModal extends StatefulWidget {
  final ProductModel product;

  const AddToCartModal({super.key, required this.product});

  static void show(ProductModel product) {
    Get.bottomSheet(
      AddToCartModal(product: product),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<AddToCartModal> createState() => _AddToCartModalState();
}

class _AddToCartModalState extends State<AddToCartModal> {
  int selectedQuantity = 1;
  bool showCustomInput = false;
  final TextEditingController customQuantityController = TextEditingController();

  @override
  void dispose() {
    customQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 47,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Product Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE8EAE8)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  padding: const EdgeInsets.all(5.29),
                  child: Image.asset(
                    widget.product.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF191930),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 7),

                      // Quantity Info
                      Text(
                        'Quantity: $selectedQuantity (${widget.product.moq})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xB301060F),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Price
                      Text(
                        widget.product.priceDisplay,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF064E36),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quantity Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantity (${widget.product.moq})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF01060F),
                  ),
                ),
                const SizedBox(height: 8),
                _buildQuantitySelector(),
                if (showCustomInput) ...[
                  const SizedBox(height: 12),
                  _buildCustomQuantityInput(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Continue Shopping
                Expanded(
                  child: CustomButton(
                    text: 'Continue',
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.medium,
                    textColor: AppColors.textPrimary,
                    fullWidth: true,
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Add to Cart
                Expanded(
                  child: CustomButton(
                    text: 'Add to Cart',
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                    fullWidth: true,
                    onPressed: () {
                      final cartController = Get.find<CartController>();

                      // Add to cart with selected quantity
                      cartController.addToCart(widget.product, quantity: selectedQuantity);

                      // Close modal
                      Get.back();

                      // Show success message
                      Get.snackbar(
                        'Added to Cart',
                        '$selectedQuantity ${widget.product.moq} of ${widget.product.name} added',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF064E36),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    // Pre-defined quantities
    final quantities = [1, 5, 10, 20];

    return Wrap(
      spacing: 9,
      children: [
        // Quantity buttons
        ...quantities.map((qty) {
          final isSelected = selectedQuantity == qty && !showCustomInput;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedQuantity = qty;
                showCustomInput = false;
                customQuantityController.clear();
              });
            },
            child: Container(
              width: 57.5,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF064E36) : const Color(0xFFFAFAFA),
                border: Border.all(
                  color: isSelected ? const Color(0xFF064E36) : const Color(0xFFE8EAE8),
                  width: 0.75,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: Text(
                qty.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF01060F),
                ),
              ),
            ),
          );
        }).toList(),

        // Custom button
        GestureDetector(
          onTap: () {
            setState(() {
              showCustomInput = !showCustomInput;
              if (showCustomInput) {
                // Focus on the text field when showing it
                Future.delayed(const Duration(milliseconds: 100), () {
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              }
            });
          },
          child: Container(
            width: 57.5,
            height: 24,
            decoration: BoxDecoration(
              color: showCustomInput ? const Color(0xFF064E36) : const Color(0xFFFAFAFA),
              border: Border.all(
                color: showCustomInput ? const Color(0xFF064E36) : const Color(0xFFE8EAE8),
                width: 0.75,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: Text(
              'Custom',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: showCustomInput ? Colors.white : const Color(0xFF01060F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomQuantityInput() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: customQuantityController,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF01060F),
        ),
        decoration: InputDecoration(
          hintText: 'Enter custom quantity',
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFFA2A8AF),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: customQuantityController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.check, color: Color(0xFF064E36), size: 20),
                  onPressed: () {
                    final customQty = int.tryParse(customQuantityController.text);
                    if (customQty != null && customQty > 0) {
                      setState(() {
                        selectedQuantity = customQty;
                      });
                    }
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
        },
        onSubmitted: (value) {
          final customQty = int.tryParse(value);
          if (customQty != null && customQty > 0) {
            setState(() {
              selectedQuantity = customQty;
            });
          }
        },
      ),
    );
  }
}



