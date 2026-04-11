import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../../home/models/product_model.dart';
import '../controllers/product_details_controller.dart';

class MedicineOverviewView extends StatelessWidget {
  const MedicineOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductModel product;
    if (Get.arguments is ProductModel) {
      product = Get.arguments as ProductModel;
    } else if (Get.isRegistered<ProductDetailsController>()) {
      product = Get.find<ProductDetailsController>().product;
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFCFC),
        appBar: PrimaryAppBar(
          title: 'Medicine Overview',
          showBackButton: true,
          backgroundColor: Colors.white,
        ),
        body: const Center(child: Text('Medicine details are unavailable.')),
      );
    }

    final intro = _firstNonEmpty(<String?>[
      product.description,
      '${product.name} is a medicine product available in this catalog.',
    ]);

    final uses = <String>[
      if (product.categoryName.trim().isNotEmpty) 'Category: ${product.categoryName}',
      if (product.brand.trim().isNotEmpty && product.brand.toLowerCase() != 'unknown brand')
        'Brand: ${product.brand}',
      if (product.moq.trim().isNotEmpty) 'Pack/Unit: ${product.moq}',
      'Price: ${product.priceDisplay}',
    ];

    final summary = <String>[
      if (product.description != null && product.description!.trim().isNotEmpty)
        product.description!.trim(),
      if (product.offerLabel != null && product.offerLabel!.trim().isNotEmpty)
        'Offer: ${product.offerLabel}',
      'For proper use, follow your physician\'s guidance and product instructions.',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: '${product.name} Overview',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            'Introduction',
            intro,
            showMore: true,
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Product Details',
            uses.isEmpty ? 'Product details are currently limited.' : uses.map((item) => '• $item').join('\n'),
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Overview',
            summary.join('\n\n'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = (value ?? '').trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return 'Medicine information is not available for this product right now.';
  }

  Widget _buildSection(String title, String content, {bool showMore = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF01060F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xB301060F),
          ),
        ),
        if (showMore)
          TextButton(
            onPressed: () {
              // Toggle expand/collapse
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See More',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF064E36),
              ),
            ),
          ),
      ],
    );
  }
}


