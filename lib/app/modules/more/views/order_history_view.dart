import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widgets/app_tag_chip.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/order_controller.dart';

class OrderHistoryView extends GetView<OrderController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'My Orders',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        final tab = controller.activeTab.value;
        final orders = switch (tab) {
          OrderTab.current => controller.currentOrders,
          OrderTab.completed => controller.completedOrders,
          OrderTab.canceled => controller.canceledOrders,
        };

        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty && controller.orders.isEmpty) {
          return _StatusView(
            icon: Icons.error_outline,
            title: 'Could not load orders',
            message: controller.errorMessage.value,
            buttonText: 'Retry',
            onPressed: controller.loadMyOrders,
          );
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            _OrderTabs(
              selectedTab: tab,
              onTabChanged: controller.setActiveTab,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadMyOrders(),
                child: orders.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.58,
                            child: _StatusView(
                              icon: Icons.inventory_2_outlined,
                              title: _emptyTitle(tab),
                              message: _emptyMessage(tab),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final order = orders[index];
                          return _OrderCard(
                            order: order,
                            activeTab: tab,
                            controller: controller,
                            onCancel: () => _showCancelOrderDialog(context, order),
                            onReturn: () => _showReturnOrderDialog(context, order),
                            onDetails: () => _openOrderDetails(order),
                            onReview: () => _openReview(order),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  void _openOrderDetails(Map<String, dynamic> order) {
    final orderId = controller.orderIdOf(order);
    if (orderId.isEmpty) {
      _showComingSoon('Order details not available.');
      return;
    }
    Get.toNamed(Routes.ORDER_DETAILS, arguments: orderId);
  }

  Future<void> _showCancelOrderDialog(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final orderId = controller.orderIdOf(order);
    if (orderId.isEmpty) {
      _showComingSoon('Order details not available.');
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
              child: controller.isMutating.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReturnOrderDialog(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final orderId = controller.orderIdOf(order);
    if (orderId.isEmpty) {
      _showComingSoon('Order details not available.');
      return;
    }

    final reasonController = TextEditingController();
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Return Order'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write return reason',
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
                      final ok = await controller.returnOrder(
                        orderId: orderId,
                        reason: reasonController.text,
                      );
                      if (ok) {
                        Get.back();
                        Get.snackbar('Success', 'Return request submitted.');
                      } else {
                        Get.snackbar('Failed', controller.errorMessage.value);
                      }
                    },
              child: controller.isMutating.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReview(Map<String, dynamic> order) async {
    final productId = controller.firstProductIdOf(order);
    final orderId = controller.orderIdOf(order);
    final variantId = controller.firstVariantIdOf(order);
    final item = controller.firstItemOf(order);

    if (productId.isEmpty) {
      _showComingSoon('No reviewable product found in this order.');
      return;
    }

    final result = await Get.toNamed(
      Routes.WRITE_REVIEW,
      arguments: {
        'productId': productId,
        'orderId': orderId,
        'variantId': variantId,
        'item': item,
        'canReview': controller.canReviewOrder(order),
      },
    );

    if (result == true) {
      await controller.loadMyOrders();
    }
  }

  void _showComingSoon(String message) {
    Get.snackbar('Info', message, snackPosition: SnackPosition.BOTTOM);
  }

  String _emptyTitle(OrderTab tab) {
    switch (tab) {
      case OrderTab.current:
        return 'No current orders';
      case OrderTab.completed:
        return 'No completed orders';
      case OrderTab.canceled:
        return 'No canceled orders';
    }
  }

  String _emptyMessage(OrderTab tab) {
    switch (tab) {
      case OrderTab.current:
        return 'Your active orders will show here.';
      case OrderTab.completed:
        return 'Completed orders will show here.';
      case OrderTab.canceled:
        return 'Canceled orders will show here.';
    }
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({required this.selectedTab, required this.onTabChanged});

  final OrderTab selectedTab;
  final ValueChanged<OrderTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _OrderTabButton(
              label: 'Current orders',
              isSelected: selectedTab == OrderTab.current,
              onTap: () => onTabChanged(OrderTab.current),
            ),
          ),
          Expanded(
            child: _OrderTabButton(
              label: 'Completed',
              isSelected: selectedTab == OrderTab.completed,
              onTap: () => onTabChanged(OrderTab.completed),
            ),
          ),
          Expanded(
            child: _OrderTabButton(
              label: 'Canceled',
              isSelected: selectedTab == OrderTab.canceled,
              onTap: () => onTabChanged(OrderTab.canceled),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTabButton extends StatelessWidget {
  const _OrderTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF064E36) : const Color(0xB301060F),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                color: isSelected ? const Color(0xFF064E36) : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.activeTab,
    required this.controller,
    required this.onCancel,
    required this.onReturn,
    required this.onDetails,
    required this.onReview,
  });

  final Map<String, dynamic> order;
  final OrderTab activeTab;
  final OrderController controller;
  final VoidCallback onCancel;
  final VoidCallback onReturn;
  final VoidCallback onDetails;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final orderNo = controller.orderNumberOf(order);
    final delivery = controller.estimatedDeliveryOf(order);
    final amount = controller.orderAmountTextOf(order);
    final status = controller.orderStatusLabelOf(order);
    final canCancel = controller.canCancelOrder(order);
    final canReturn = controller.canReturnOrder(order);
    final canReview = controller.canReviewOrder(order);

    late final String leftButtonText;
    late final String rightButtonText;
    late final VoidCallback? leftAction;
    late final VoidCallback? rightAction;

    if (activeTab == OrderTab.completed) {
      leftButtonText = 'Return Order';
      rightButtonText = canReview ? 'Review' : 'Reviewed';
      leftAction = canReturn ? onReturn : null;
      rightAction = canReview ? onReview : null;
    } else {
      leftButtonText = canCancel ? 'Cancel Order' : 'View Details';
      rightButtonText = 'View Details';
      leftAction = canCancel ? onCancel : onDetails;
      rightAction = onDetails;
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderNo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xB301060F),
                ),
              ),
              AppTagChip(
                text: status,
                backgroundColor: _statusBackground(status),
                textColor: _statusTextColor(status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE8EAEB)),
          const SizedBox(height: 10),
          _InfoRow(label: 'Estimated Delivery :', value: delivery),
          const SizedBox(height: 8),
          _InfoRow(label: 'Amount :', value: amount),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: leftButtonText,
                  onPressed: controller.isMutating.value ? null : leftAction,
                  variant: ButtonVariant.tertiary,
                  size: ButtonSize.small,
                  fullWidth: true,
                  textColor: leftButtonText == 'Cancel Order'
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF43505C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: rightButtonText,
                  onPressed: controller.isMutating.value ? null : rightAction,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.small,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusBackground(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) return const Color(0x1AEF4444);
    if (lower.contains('deliver') || lower.contains('refund') || lower.contains('return')) {
      return const Color(0x1A064E36);
    }
    return const Color(0x1A43505C);
  }

  Color _statusTextColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) return const Color(0xFFEF4444);
    if (lower.contains('deliver') || lower.contains('refund') || lower.contains('return')) {
      return const Color(0xFF064E36);
    }
    return const Color(0xFF43505C);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xB3191930),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF191930),
          ),
        ),
      ],
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 54, color: const Color(0xFFA2A8AF)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF01060F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xB301060F),
              ),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
