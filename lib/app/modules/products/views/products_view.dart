import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/models/product_model.dart';
import '../../home/views/widgets/product_card.dart';
import '../../home/views/widgets/section_header.dart';
import '../controllers/products_controller.dart';
import '../models/products_query.dart';
import 'widgets/offer_product_tile.dart';
import 'widgets/products_header.dart';
import '../../../data/repositories/product_repository.dart';

class ProductsView extends StatefulWidget {
  final ProductsQuery query;

  const ProductsView({super.key, this.query = const ProductsQuery.main()});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  late final String _tag;
  late final ProductsController _controller;
  late final ProductsQuery _query;

  @override
  void initState() {
    super.initState();
    _query = Get.arguments is ProductsQuery
        ? Get.arguments as ProductsQuery
        : widget.query;
    _tag =
        'products_${_query.type.name}_${_query.title}_${_query.keyword ?? ''}';
    if (!Get.isRegistered<ProductRepository>()) {
      Get.put(ProductRepository(), permanent: true);
    }
    _controller = Get.put(ProductsController(_query), tag: _tag);
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<ProductsController>(tag: _tag)) {
      Get.delete<ProductsController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: Column(
        children: [
          ProductsHeader(
            title: _query.title,
            showBackButton: _query.showBackButton,
          ),
          const SizedBox(height: 16),
          _SearchAndFilterBar(onSearch: _controller.onSearchChanged),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF064E36)),
                );
              }

              if (_query.type == ProductListingType.brand) {
                return _BrandProductsBody(controller: _controller);
              }

              return _ProductsGrid(products: _controller.filteredProducts);
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const _SearchAndFilterBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE8EAE8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFFA2A8AF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: onSearch,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: 'Search Your Needs...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFA2A8AF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE8EAE8)),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF01060F)),
          ),
        ],
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;
  final bool nested;

  const _ProductsGrid({required this.products, this.nested = false});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: nested,
      physics: nested
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 169 / 225,
      ),
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

class _BrandProductsBody extends StatelessWidget {
  final ProductsController controller;

  const _BrandProductsBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        SectionHeader(title: 'New Products', onViewAll: () {}),
        const SizedBox(height: 12),
        _ProductsGrid(products: controller.brandNewProducts, nested: true),
        const SizedBox(height: 16),
        SectionHeader(title: 'Offer Products', extra: const OfferTimer()),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: controller.brandOfferProducts
                .take(3)
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OfferProductTile(product: product),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'All Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ProductsGrid(products: controller.brandAllProducts, nested: true),
      ],
    );
  }
}
