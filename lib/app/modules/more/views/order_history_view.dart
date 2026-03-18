import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
		if (controller.isLoading.value && controller.orders.isEmpty) {
		  return const Center(child: CircularProgressIndicator());
		}

		if (controller.errorMessage.value.isNotEmpty &&
			controller.orders.isEmpty) {
		  return _StatusView(
			icon: Icons.error_outline,
			title: 'Could not load orders',
			message: controller.errorMessage.value,
			buttonText: 'Retry',
			onPressed: controller.loadMyOrders,
		  );
		}

		if (controller.orders.isEmpty) {
		  return const _StatusView(
			icon: Icons.shopping_bag_outlined,
			title: 'No orders yet',
			message: 'Your placed orders will appear here.',
		  );
		}

		return RefreshIndicator(
		  onRefresh: () => controller.loadMyOrders(),
		  child: ListView.separated(
			padding: const EdgeInsets.all(16),
			itemCount: controller.orders.length,
			separatorBuilder: (_, __) => const SizedBox(height: 12),
			itemBuilder: (_, index) {
			  final order = controller.orders[index];
			  final id = controller.orderIdOf(order);
			  final number = controller.orderNumberOf(order);
			  final status = controller.orderStatusOf(order);
			  final total = controller.orderTotalOf(order);

			  return InkWell(
				onTap: () => Get.toNamed(Routes.ORDER_DETAILS, arguments: id),
				borderRadius: BorderRadius.circular(8),
				child: Container(
				  padding: const EdgeInsets.all(14),
				  decoration: BoxDecoration(
					color: Colors.white,
					border: Border.all(color: const Color(0xFFE8EAE8)),
					borderRadius: BorderRadius.circular(8),
				  ),
				  child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
					  Row(
						children: [
						  Expanded(
							child: Text(
							  'Order #$number',
							  style: const TextStyle(
								fontSize: 15,
								fontWeight: FontWeight.w600,
								color: Color(0xFF01060F),
							  ),
							),
						  ),
						  Container(
							padding: const EdgeInsets.symmetric(
							  horizontal: 10,
							  vertical: 4,
							),
							decoration: BoxDecoration(
							  color: const Color(0x1A064E36),
							  borderRadius: BorderRadius.circular(999),
							),
							child: Text(
							  status,
							  style: const TextStyle(
								fontSize: 11,
								fontWeight: FontWeight.w600,
								color: Color(0xFF064E36),
							  ),
							),
						  ),
						],
					  ),
					  const SizedBox(height: 8),
					  Text(
						'Total: ৳${total.toStringAsFixed(2)}',
						style: const TextStyle(
						  fontSize: 13,
						  fontWeight: FontWeight.w500,
						  color: Color(0xB301060F),
						),
					  ),
					  if (id.isNotEmpty) ...[
						const SizedBox(height: 6),
						Text(
						  'ID: $id',
						  style: const TextStyle(
							fontSize: 11,
							color: Color(0x9901060F),
						  ),
						),
					  ],
					],
				  ),
				),
			  );
			},
		  ),
		);
	  }),
	);
  }
}

class _StatusView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const _StatusView({
	required this.icon,
	required this.title,
	required this.message,
	this.buttonText,
	this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
	return Center(
	  child: Padding(
		padding: const EdgeInsets.symmetric(horizontal: 24),
		child: Column(
		  mainAxisAlignment: MainAxisAlignment.center,
		  children: [
			Icon(icon, size: 56, color: const Color(0xFF8D949D)),
			const SizedBox(height: 12),
			Text(
			  title,
			  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
			),
			const SizedBox(height: 8),
			Text(
			  message,
			  textAlign: TextAlign.center,
			  style: const TextStyle(fontSize: 13, color: Color(0xB301060F)),
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


