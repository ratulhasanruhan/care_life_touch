import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import 'widgets/home_header.dart';
import 'widgets/section_header.dart';
import 'widgets/categories_list.dart';
import 'widgets/offer_banners.dart';
import 'widgets/product_card.dart';
import 'all_categories_view.dart';
import 'all_brands_view.dart';
import '../../products/models/products_query.dart';
import '../../../routes/app_pages.dart';

SliverGridDelegateWithFixedCrossAxisCount _responsiveGridDelegate(
  double maxWidth,
) {
  const spacing = 12.0;
  const crossAxisCount = 2;
  final cardWidth =
      (maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
  final cardHeight = cardWidth < 150
      ? 232.0
      : cardWidth < 190
      ? 246.0
      : 262.0;

  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: spacing,
    mainAxisSpacing: spacing,
    childAspectRatio: cardWidth / cardHeight,
  );
}

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
          Obx(
            () => HomeHeader(
              locationText: controller.locationText.value,
              isLocationLoading: controller.isResolvingLocation.value,
              hasLocationError: controller.hasLocationError.value,
              onLocationTap: controller.onLocationTap,
              unreadNotificationCount: controller.unreadNotificationCount.value,
              onNotificationTap: controller.onNotificationTap,
              onSearch: controller.onSearch,
              onSearchChanged: controller.onSearchTextChanged,
              isSearchingSuggestions:
                  controller.isSearchSuggestionsLoading.value,
              searchSuggestions: controller.searchSuggestions,
            ),
          ),

          // Scrollable Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const _HomeSkeleton();
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
                          Get.to(
                            () => AllCategoriesView(
                              categories: controller.categories,
                              onCategoryTap: (category) {
                                final categoryTitle =
                                    (category['name'] ?? 'Category')
                                        .toString()
                                        .trim();
                                final categoryKeyword =
                                    (category['query'] ?? categoryTitle)
                                        .toString()
                                        .trim();
                                Get.toNamed(
                                  Routes.PRODUCTS,
                                  arguments: ProductsQuery(
                                    type: ProductListingType.category,
                                    title: categoryTitle,
                                    keyword: categoryKeyword,
                                  ),
                                );
                              },
                            ),
                          );
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
                          Get.toNamed(
                            Routes.PRODUCTS,
                            arguments: const ProductsQuery(
                              type: ProductListingType.trending,
                              title: 'Trending Products',
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildProductGrid(controller.trendingProducts),

                      const SizedBox(height: 16),

                      // Brands Section
                      SectionHeader(
                        title: 'Brands',
                        onViewAll: () {
                          Get.to(
                            () => AllBrandsView(
                              brands: controller.brands,
                              onBrandTap: (brandValue) {
                                Map<String, String>? matchedBrand;
                                for (final item in controller.brands) {
                                  final query = (item['query'] ?? '').trim();
                                  final name = (item['name'] ?? '').trim();
                                  final selectedQuery =
                                      (brandValue['query'] ?? '')
                                          .toString()
                                          .trim();
                                  final selectedName =
                                      (brandValue['name'] ?? '')
                                          .toString()
                                          .trim();
                                  if (selectedQuery == query ||
                                      selectedQuery == name ||
                                      selectedName == query ||
                                      selectedName == name) {
                                    matchedBrand = item;
                                    break;
                                  }
                                }

                                final brandTitle =
                                    (matchedBrand?['name'] ??
                                            brandValue['name'] ??
                                            'Brand')
                                        .toString()
                                        .trim();
                                final brandKeyword =
                                    (matchedBrand?['query'] ??
                                            brandValue['query'] ??
                                            brandTitle)
                                        .toString()
                                        .trim();

                                Get.toNamed(
                                  Routes.PRODUCTS,
                                  arguments: ProductsQuery(
                                    type: ProductListingType.brand,
                                    title: brandTitle,
                                    keyword: brandKeyword,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildBrands(),

                      const SizedBox(height: 16),

                      // New Products Section
                      SectionHeader(
                        title: 'New Products',
                        onViewAll: () {
                          Get.toNamed(
                            Routes.PRODUCTS,
                            arguments: const ProductsQuery(
                              type: ProductListingType.newArrival,
                              title: 'New Products',
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildProductGrid(controller.newProducts),

                      const SizedBox(height: 16),

                      // Offers Product Section
                      SectionHeader(
                        title: 'Offers Product',
                        onViewAll: () {
                          Get.toNamed(
                            Routes.PRODUCTS,
                            arguments: const ProductsQuery(
                              type: ProductListingType.offers,
                              title: 'Offer Products',
                            ),
                          );
                        },
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
    return CategoriesList(
      categories: controller.categories,
      onCategoryTap: (category) {
        final categoryTitle = (category['name'] ?? 'Category')
            .toString()
            .trim();
        final categoryKeyword = (category['query'] ?? categoryTitle)
            .toString()
            .trim();
        Get.toNamed(
          Routes.PRODUCTS,
          arguments: ProductsQuery(
            type: ProductListingType.category,
            title: categoryTitle,
            keyword: categoryKeyword,
          ),
        );
      },
    );
  }

  /// Offer banners carousel
  Widget _buildOfferBanners() {
    return OfferBannersCarousel(banners: controller.banners);
  }

  /// Product grid widget
  Widget _buildProductGrid(RxList products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: _responsiveGridDelegate(constraints.maxWidth),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        ),
      ),
    );
  }

  /// Brands horizontal list
  Widget _buildBrands() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.brands.length,
        itemBuilder: (context, index) {
          final brand = controller.brands[index];
          return Container(
            width: 84,
            margin: EdgeInsets.only(
              right: index < controller.brands.length - 1 ? 10 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                final brandName = brand['query'] ?? brand['name'] ?? '';
                Get.toNamed(
                  Routes.PRODUCTS,
                  arguments: ProductsQuery(
                    type: ProductListingType.brand,
                    title: brand['name'] ?? 'Brand',
                    keyword: brandName,
                  ),
                );
              },
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
                        child: _buildImage(brand['image'] ?? ''),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Brand Name
                  Text(
                    brand['name'] ?? '',
                    style: const TextStyle(
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

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, color: Color(0xFFE8EAE8)),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported, color: Color(0xFFE8EAE8)),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFEDEDED),
          highlightColor: const Color(0xFFF7F7F7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SkeletonLine(width: 180, height: 18),
              const SizedBox(height: 10),
              _buildCategorySkeleton(),
              const SizedBox(height: 20),
              const _SkeletonBox(height: 160),
              const SizedBox(height: 20),
              const _SkeletonLine(width: 140, height: 18),
              const SizedBox(height: 10),
              _buildGridSkeleton(),
              const SizedBox(height: 20),
              const _SkeletonLine(width: 90, height: 18),
              const SizedBox(height: 10),
              _buildBrandSkeleton(),
              const SizedBox(height: 20),
              const _SkeletonLine(width: 120, height: 18),
              const SizedBox(height: 10),
              _buildGridSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySkeleton() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => const Column(
          children: [
            _SkeletonBox(width: 80, height: 80),
            SizedBox(height: 8),
            _SkeletonBox(width: 64, height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSkeleton() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => const Column(
          children: [
            _SkeletonBox(width: 80, height: 80),
            SizedBox(height: 8),
            _SkeletonBox(width: 70, height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: _responsiveGridDelegate(constraints.maxWidth),
          itemBuilder: (_, __) => const _SkeletonBox(),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SkeletonBox(width: width, height: height),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;

  const _SkeletonBox({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
