import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../../home/models/product_model.dart';
import '../controllers/product_details_controller.dart';
import '../../../data/providers/api_provider.dart';

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

    // Keep existing summary information from the ProductModel but also try to
    // fetch full product details (specifications, tags, extended description)
    // when a slug is available. We use a FutureBuilder so the UI renders the
    // existing info immediately and enhances it when full payload arrives.

    final intro = _firstNonEmpty(<String?>[
      product.description,
      '${product.name} is a medicine product available in this catalog.',
    ]);

    final uses = <String>[
      if (product.categoryName.trim().isNotEmpty) 'Category: ${product.categoryName}',
      if (product.brand.trim().isNotEmpty && product.brand.toLowerCase() != 'unknown brand')
        'Brand: ${product.brand}',
      if (product.genericName != null && product.genericName!.trim().isNotEmpty)
        'Generic: ${product.genericName}',
      if (product.strength != null && product.strength!.trim().isNotEmpty)
        'Strength: ${product.strength}',
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

    Future<Map<String, dynamic>?> _fetchFullProduct() async {
      final slug = product.slug;
      if (slug == null || slug.trim().isEmpty) return null;
      try {
        final api = Get.find<ApiProvider>();
        final res = await api.getData('/get-product-by-slug/${Uri.encodeComponent(slug)}');
        if (res is Map) {
          final map = res.map((k, v) => MapEntry(k.toString(), v));
          final prod = map['product'];
          if (prod is Map) return prod.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {
        // ignore network errors; we'll just show model data
      }
      return null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: '${product.name} Overview',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchFullProduct(),
        builder: (context, snapshot) {
          final full = snapshot.data;

          // Use description from full payload when available, otherwise ProductModel
          final description = (full != null
                  ? (full['description'] ?? full['shortDescription'])
                  : product.description)
              ?.toString();

          // Extract specifications and tags from full payload when available
          final Map<String, dynamic> specs = {};
          if (full != null && full['specifications'] is Map) {
            final raw = full['specifications'] as Map;
            raw.forEach((k, v) => specs[k.toString()] = v);
          }

          final List<String> tags = [];
          if (full != null && full['tags'] is List) {
            for (final t in full['tags']) {
              if (t == null) continue;
              if (t is String) {
                final s = t.trim();
                if (s.isNotEmpty) tags.add(s);
              } else if (t is Map && t['name'] is String) {
                final s = (t['name'] as String).trim();
                if (s.isNotEmpty) tags.add(s);
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSection('Introduction', intro, showMore: false),
              const SizedBox(height: 16),
              _buildSection('Product Details', uses.isEmpty
                  ? 'Product details are currently limited.'
                  : uses.map((item) => '• $item').join('\n')),
              const SizedBox(height: 16),
              _buildSection('Overview', summary.join('\n\n')),
              const SizedBox(height: 16),
              _buildSection('Description', description ?? 'Description is not available for this product.'),
              const SizedBox(height: 16),
              _buildSection('Specifications', specs.isEmpty
                  ? 'Specifications are not available for this product.'
                  : specs.entries.map((e) => '${_prettyKey(e.key)}: ${e.value ?? ''}').join('\n')),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSection('Tags', tags.join(', ')),
              ],
              const SizedBox(height: 20),
            ],
          );
        },
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

  String _prettyKey(String key) {
    var s = key.replaceAll('_', ' ').replaceAll('-', ' ');
    s = s.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
    s = s.trim();
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
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


