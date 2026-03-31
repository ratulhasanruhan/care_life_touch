import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../global_widgets/app_tag_chip.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/order_controller.dart';

class OrderDetailsView extends GetView<OrderController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = (Get.arguments ?? '').toString();

    if (orderId.isNotEmpty) {
      final loadedId = controller.selectedOrder.value == null
          ? ''
          : controller.orderIdOf(controller.selectedOrder.value!);
      if (loadedId != orderId && !controller.isLoading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadOrderDetails(orderId);
        });
      }
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Color(0xFFA2A8AF)),
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

        final items = _extractItems(order);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderSummaryCard(order: order, controller: controller),
              if (_shouldShowTracking(order)) ...[
                const SizedBox(height: 12),
                _TrackingDetailsCard(order: order),
              ],
              const SizedBox(height: 16),
              const Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProductItemCard(item: item),
                  )),
              const SizedBox(height: 8),
              const Text(
                'Shipping address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 12),
              _ShippingCard(order: order),
              const SizedBox(height: 16),
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 12),
              _PaymentDetailsCard(order: order, controller: controller),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null || !controller.canCancelOrder(order)) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8EAE8))),
            ),
            child: CustomButton(
              text: 'Cancel Order',
              onPressed: controller.isMutating.value
                  ? null
                  : () => _showCancelOrderDialog(context, order),
              variant: ButtonVariant.tertiary,
              size: ButtonSize.medium,
              fullWidth: true,
              textColor: const Color(0xFFEF4444),
              isLoading: controller.isMutating.value,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _showCancelOrderDialog(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final orderId = controller.orderIdOf(order);
    if (orderId.isEmpty) {
      Get.snackbar('Failed', 'Order id missing.');
      return;
    }

    final reasonController = TextEditingController();
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write cancellation reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          Obx(
            () => TextButton(
              onPressed: controller.isMutating.value
                  ? null
                  : () async {
                      final ok = await controller.cancelOrder(
                        orderId: orderId,
                        reason: reasonController.text,
                      );
                      if (ok) {
                        Get.back();
                        Get.snackbar('Success', 'Order cancelled successfully.');
                      } else {
                        Get.snackbar('Failed', controller.errorMessage.value);
                      }
                    },
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> order) {
    final raw = order['items'] ?? order['products'] ?? order['orderItems'];
    if (raw is! List) return const [];

    return raw.whereType<Map>().map((entry) {
      final item = entry.map((k, v) => MapEntry(k.toString(), v));
      final nested = item['product'];
      if (nested is Map) {
        final product = nested.map((k, v) => MapEntry(k.toString(), v));
        return {
          ...item,
          if ((item['name'] ?? '').toString().trim().isEmpty) 'name': product['name'],
        };
      }
      return item;
    }).toList(growable: false);
  }

  bool _shouldShowTracking(Map<String, dynamic> order) {
    final status = (order['status'] ?? '').toString().trim().toLowerCase();
    if (status != 'shipped') return false;

    final tracking = _toMap(order['tracking']);
    if (tracking == null) return false;

    final trackingNo = _asText(tracking['trackingNo']);
    final courier = _asText(tracking['courier']);
    final consignmentId = _asText(tracking['consignmentId']);
    final estimatedDelivery = _asText(tracking['estimatedDelivery']);

    return trackingNo.isNotEmpty ||
        courier.isNotEmpty ||
        consignmentId.isNotEmpty ||
        estimatedDelivery.isNotEmpty;
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  String _asText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }
}

class _TrackingDetailsCard extends StatelessWidget {
  const _TrackingDetailsCard({required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final tracking = _toMap(order['tracking']) ?? const <String, dynamic>{};

    final courier = _asText(tracking['courier']);
    final trackingNo = _asText(tracking['trackingNo']);
    final consignmentId = _asText(tracking['consignmentId']);
    final estimatedDelivery = _asText(tracking['estimatedDelivery']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
          const SizedBox(height: 10),
          if (courier.isNotEmpty) _trackingRow('Courier', courier),
          if (trackingNo.isNotEmpty) _trackingRow('Tracking No', trackingNo, copyable: true),
          if (consignmentId.isNotEmpty) _trackingRow('Consignment Id', consignmentId),
          if (estimatedDelivery.isNotEmpty)
            _trackingRow('Estimated Delivery', _formatDate(estimatedDelivery)),
        ],
      ),
    );
  }

  Widget _trackingRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xB301060F),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF01060F),
                    ),
                  ),
                ),
                if (copyable)
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar(
                        'Copied',
                        '$label copied',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: Color(0xFF43505C),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String input) {
    final dt = DateTime.tryParse(input)?.toLocal();
    if (dt == null) return input;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  String _asText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order, required this.controller});

  final Map<String, dynamic> order;
  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    final orderNo = controller.orderNumberOf(order);
    final status = controller.orderStatusLabelOf(order);
    final delivery = controller.estimatedDeliveryOf(order);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  orderNo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xB301060F),
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE8EAEB)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Estimated Delivery :',
                  style: TextStyle(fontSize: 14, color: Color(0xB3191930)),
                ),
              ),
              Text(
                delivery,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF191930),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final isDone = lower.contains('deliver') || lower.contains('refund');
    final isCanceled = lower.contains('cancel');

    final bg = isDone
        ? const Color(0x1A22C55E)
        : isCanceled
            ? const Color(0x1AEF4444)
            : const Color(0x1AEAB308);

    final fg = isDone
        ? const Color(0xFF22C55E)
        : isCanceled
            ? const Color(0xFFEF4444)
            : const Color(0xFFEAB308);

    return AppTagChip(
      text: status,
      backgroundColor: bg,
      textColor: fg,
      borderRadius: 4,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }
}

class _ProductItemCard extends StatelessWidget {
  const _ProductItemCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final image = (item['image'] ?? '').toString();
    final name = (item['name'] ?? 'Product').toString();
    final unit = ((item['variant'] is Map ? item['variant']['unit'] : null) ?? '').toString();
    final quantity = _asInt(item['quantity']);
    final price = _asDouble(item['price']);
    final oldPrice = _asDouble(item['oldPrice'] ?? item['mrp']);

    return Container(
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
              child: image.trim().isEmpty
                  ? const Icon(Icons.image_outlined, color: Color(0xFFA2A8AF))
                  : Image.network(image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTagChip(
                  text: unit.isEmpty ? 'Medicine' : unit,
                  backgroundColor: const Color(0xFFF6F6F6),
                  textColor: const Color(0xFF43505C),
                  borderRadius: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF191930),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '৳${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF064E36),
                      ),
                    ),
                    if (oldPrice > price && oldPrice > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '৳${oldPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA2A8AF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Quantity: $quantity',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xB301060F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _ShippingCard extends StatelessWidget {
  const _ShippingCard({required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final snapshot = _toMap(order['shippingAddressSnapshot']);
    final address = _toMap(order['shippingAddress']);
    final location = _toMap(address?['location']);

    final type = _firstNonEmpty([
      snapshot?['addressType'],
      address?['addressType'],
      'Address',
    ]);

    final name = _firstNonEmpty([
      snapshot?['fullName'],
      snapshot?['name'],
      address?['recipientName'],
      address?['fullName'],
      address?['name'],
      order['buyerName'],
      '--',
    ]);

    final phone = _firstNonEmpty([
      snapshot?['phone'],
      snapshot?['mobile'],
      address?['recipientPhone'],
      address?['phone'],
      order['buyerPhone'],
      '--',
    ]);

    final fullAddress = _firstNonEmpty([
      snapshot?['fullAddress'],
      snapshot?['formattedAddress'],
      address?['fullAddress'],
      address?['addressLine'],
      location?['formattedAddress'],
      '--',
    ]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA2A8AF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF01060F),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            phone,
            style: const TextStyle(fontSize: 12, color: Color(0xFF01060F)),
          ),
          const SizedBox(height: 6),
          Text(
            fullAddress,
            style: const TextStyle(fontSize: 12, color: Color(0xB301060F)),
          ),
        ],
      ),
    );
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return '--';
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }
}

class _PaymentDetailsCard extends StatelessWidget {
  const _PaymentDetailsCard({required this.order, required this.controller});

  final Map<String, dynamic> order;
  final OrderController controller;

  @override
  Widget build(BuildContext context) {
    final totalProduct = controller.orderItemCountOf(order);
    final subtotal = _asDouble(order['subtotal']);
    final discount = _asDouble(order['discount']);
    final shipping = _asDouble(order['shippingCharge']);
    final total = controller.orderTotalOf(order);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _row('Total Product:', '$totalProduct item'),
          const SizedBox(height: 8),
          _row('Total Price:', _money(subtotal), valueColor: const Color(0xFF064E36)),
          const SizedBox(height: 8),
          _row('Discount:', _money(discount)),
          const SizedBox(height: 8),
          _row('Delivery Charge:', _money(shipping)),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE8EAE8)),
          const SizedBox(height: 10),
          _row(
            'Total Payable',
            _money(total),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF01060F),
            ),
            valueStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF064E36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle ??
                const TextStyle(
                  fontSize: 14,
                  color: Color(0xB301060F),
                ),
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF01060F),
              ),
        ),
      ],
    );
  }

  String _money(double amount) => '৳${amount.toStringAsFixed(0)}';

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

