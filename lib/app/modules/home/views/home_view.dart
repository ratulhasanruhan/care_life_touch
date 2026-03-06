import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'widgets/home_header.dart';
import 'widgets/section_header.dart';
import 'widgets/categories_list.dart';
import 'widgets/offer_banners.dart';
import 'widgets/product_card.dart';

/// Home View - Optimized main screen with separated widgets
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: Column(
        children: [
          // Custom Header
          HomeHeader(
            onLocationTap: () {
              Get.snackbar('Location', 'Location picker coming soon');
            },
            onNotificationTap: () {
              Get.snackbar('Notifications', 'No new notifications');
            },
            onSearch: controller.onSearch,
          ),

          // Scrollable Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF064E36)),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.onRefresh,
                color: const Color(0xFF064E36),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Categories Section
                      SectionHeader(
                        title: 'All You Need Categories',
                        onViewAll: () {
                          Get.snackbar('Categories', 'View all categories');
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildCategories(),

                      const SizedBox(height: 16),

                      // Offer Banner Section
                      _buildOfferBanners(),

                      const SizedBox(height: 16),

                      // Trending Products Section
                      SectionHeader(
                        title: 'Trending Products',
                        onViewAll: () {
                          Get.snackbar(
                            'Trending',
                            'View all trending products',
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProductGrid(controller.trendingProducts),

                      const SizedBox(height: 16),

                      // Brands Section
                      SectionHeader(
                        title: 'Brands',
                        onViewAll: () {
                          Get.snackbar('Brands', 'View all brands');
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildBrands(),

                      const SizedBox(height: 16),

                      // New Products Section
                      SectionHeader(
                        title: 'New Products',
                        onViewAll: () {
                          Get.snackbar('New', 'View all new products');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProductGrid(controller.newProducts),

                      const SizedBox(height: 16),

                      // Offers Product Section
                      SectionHeader(
                        title: 'Offers Product',
                        onViewAll: () {
                          Get.snackbar('Offers', 'View all offer products');
                        },
                        extra: const OfferTimer(),
                      ),
                      const SizedBox(height: 12),
                      _buildProductGrid(controller.offerProducts),

                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Categories horizontal list
  Widget _buildCategories() {
    final categories = [
      {'name': 'Pharma', 'image': 'assets/demo/cat_1.png'},
      {'name': 'Unani', 'image': 'assets/demo/cat__2.png'},
      {'name': 'Tablet', 'image': 'assets/demo/cat_3.png'},
      {'name': 'Capsule', 'image': 'assets/demo/cat_4.png'},
      {'name': 'Pharma', 'image': 'assets/demo/cat_1.png'},
      {'name': 'Unani', 'image': 'assets/demo/cat__2.png'},
      {'name': 'Tablet', 'image': 'assets/demo/cat_3.png'},
      {'name': 'Capsule', 'image': 'assets/demo/cat_4.png'},
    ];

    return CategoriesList(
      categories: categories,
      onCategoryTap: controller.onCategoryTap,
    );
  }

  /// Offer banners carousel
  Widget _buildOfferBanners() {
    final banners = [
      'assets/demo/banner_1.png',
      'assets/demo/banner_2.png'
    ];

    return OfferBannersCarousel(banners: banners);
  }

  /// Product grid widget
  Widget _buildProductGrid(RxList products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 169 / 225,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            onTap: () => controller.onProductTap(products[index]),
          );
        },
      ),
    );
  }

  /// Brands horizontal list
  Widget _buildBrands() {
    final brands = [
      {'name': 'Incepta\nPharmaceu...', 'image': 'assets/demo/company_1.png'},
      {'name': 'ACME\nPharmaceu...', 'image': 'assets/demo/company_2.png'},
      {'name': 'Opsonin\nPharmaceu...', 'image': 'assets/demo/company_3.png'},
      {
        'name': 'Aristopharma\nPharmaceu...',
        'image': 'assets/demo/company_4.png',
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return Container(
            width: 80,
            margin: EdgeInsets.only(right: index < brands.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => controller.onBrandTap(brand['name']!),
              child: Column(
                children: [
                  // Brand Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          brand['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Brand Name
                  Text(
                    brand['name']!,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF01060F),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
