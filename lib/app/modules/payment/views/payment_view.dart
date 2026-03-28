import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF01060F),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF43505C)),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Methods',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...controller.methods.where((m) => m.isRecommended).map(_buildMethodTile),
                  const SizedBox(height: 20),
                  const Text(
                    'Others Payment Methods',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...controller.methods.where((m) => !m.isRecommended).map(_buildMethodTile),
                ],
              ),
            ),
          ),
          _buildBottomSummary(),
        ],
      ),
    );
  }

  Widget _buildMethodTile(PaymentMethodOption method) {
    return Obx(() {
      final selected = controller.selectedMethodKey.value == method.key;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: selected ? const Color(0xFF064E36) : const Color(0xFFE8EAE8)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ListTile(
          onTap: () => controller.selectMethod(method.key),
          dense: true,
          leading: SizedBox(
            width: 22,
            height: 22,
            child: Image.asset(
              method.iconAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF191930),
                size: 20,
              ),
            ),
          ),
          title: Text(
            method.label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF191930)),
          ),
          trailing: selected
              ? const Icon(Icons.check_circle, color: Color(0xFF064E36), size: 20)
              : const Icon(Icons.chevron_right, color: Color(0xFF01060F), size: 20),
        ),
      );
    });
  }

  Widget _buildBottomSummary() {
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
                children: [
                  Text(
                    'Subtotal: ${_money(controller.subtotal)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF01060F).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: ${_money(controller.total)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF064E36),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isProcessing.value ? null : controller.completePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF064E36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: controller.isProcessing.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _money(double amount) => '৳${amount.toStringAsFixed(0)}';
}

