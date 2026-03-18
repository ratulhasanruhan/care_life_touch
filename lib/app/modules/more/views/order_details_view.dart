import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widgets/primary_appbar.dart';
import '../controllers/order_controller.dart';

class OrderDetailsView extends GetView<OrderController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = (Get.arguments ?? '').toString();
    if (orderId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadOrderDetails(orderId);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'Order Details',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.selectedOrder.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final order = controller.selectedOrder.value;
        if (order == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Color(0xFF8D949D)),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value.isEmpty
                        ? 'Order not found'
                        : controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final id = controller.orderIdOf(order);
        final number = controller.orderNumberOf(order);
        final status = controller.orderStatusOf(order);
        final total = controller.orderTotalOf(order);
        final items = _extractItems(order);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #$number', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Status: $status'),
                  const SizedBox(height: 4),
                  Text('Total: ৳${total.toStringAsFixed(2)}'),
                  if (id.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('ID: $id', style: const TextStyle(fontSize: 12, color: Color(0x9901060F))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Text('No item details available.')
                  else
                    ...items.map((item) {
                      final name = (item['name'] ?? item['productName'] ?? item['title'] ?? 'Item').toString();
                      final qty = (item['quantity'] ?? 1).toString();
                      final price = _asDouble(item['price'] ?? item['unitPrice'] ?? item['totalPrice'] ?? 0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(name)),
                            Text('x$qty'),
                            const SizedBox(width: 12),
                            Text('৳${price.toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isMutating.value
                        ? null
                        : () => _showReasonDialog(
                              context,
                              title: 'Cancel Order',
                              onSubmit: (reason) => controller.cancelOrder(
                                orderId: id,
                                reason: reason,
                              ),
                            ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.isMutating.value
                        ? null
                        : () => _showReasonDialog(
                              context,
                              title: 'Return Order',
                              onSubmit: (reason) => controller.returnOrder(
                                orderId: id,
                                reason: reason,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E36),
                    ),
                    child: const Text('Return', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> order) {
    final raw = order['items'] ?? order['products'] ?? order['orderItems'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  void _showReasonDialog(
    BuildContext context, {
    required String title,
    required Future<bool> Function(String reason) onSubmit,
  }) {
    final controllerText = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controllerText,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          TextButton(
            onPressed: () async {
              final ok = await onSubmit(controllerText.text.trim());
              if (ok) {
                Get.back();
                Get.snackbar('Success', '$title request submitted');
              } else {
                Get.snackbar('Failed', controller.errorMessage.value);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}


