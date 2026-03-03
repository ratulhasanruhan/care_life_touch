import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Home View - Main screen with custom header and product sections
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: Column(
        children: [
          // Custom Header
          _buildCustomHeader(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Categories Section
                  _buildSectionHeader('All You Need Categories', onViewAll: () {}),
                  const SizedBox(height: 10),
                  _buildCategories(),

                  const SizedBox(height: 16),

                  // Offer Banner Section
                  _buildOfferBanners(),

                  const SizedBox(height: 16),

                  // Trending Products Section
                  _buildSectionHeader('Trending Products', onViewAll: () {}),
                  const SizedBox(height: 12),
                  _buildProductGrid(),

                  const SizedBox(height: 16),

                  // Brands Section
                  _buildSectionHeader('Brands', onViewAll: () {}),
                  const SizedBox(height: 10),
                  _buildBrands(),

                  const SizedBox(height: 16),

                  // New Products Section
                  _buildSectionHeader('New Products', onViewAll: () {}),
                  const SizedBox(height: 12),
                  _buildProductGrid(),

                  const SizedBox(height: 16),

                  // Offers Product Section
                  _buildSectionHeader('Offers Product', onViewAll: () {},
                    extra: _buildOfferTimer()),
                  const SizedBox(height: 12),
                  _buildProductGrid(),

                  const SizedBox(height: 100), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom header with green background
  Widget _buildCustomHeader() {
    return Container(
      height: 182,
      decoration: const BoxDecoration(
        color: Color(0xFF065F42),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Location and Notification Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Location Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                            color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          const Text(
                            'Deliver to',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Jessore Khulna, Bangladesh',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Notification Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAB308),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Your Needs...',
                    hintStyle: const TextStyle(
                      color: Color(0xFFA2A8AF),
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFA2A8AF),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section header with title and view all button
  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll, Widget? extra}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
          if (extra != null)
            extra
          else
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF064E36),
                ),
              ),
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
    ];

    return SizedBox(
      height: 106,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 80,
            margin: EdgeInsets.only(right: index < categories.length - 1 ? 10 : 0),
            child: Column(
              children: [
                // Category Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      category['image']!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Category Name
                Text(
                  category['name']!,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF01060F),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Offer banners with page indicator
  Widget _buildOfferBanners() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView(
            children: [
              _buildBannerCard('assets/demo/banner_1.png'),
              _buildBannerCard('assets/demo/banner_2.png'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF064E36),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerCard(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// Product grid (2 columns)
  Widget _buildProductGrid() {
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
        itemCount: 4,
        itemBuilder: (context, index) {
          return _buildProductCard(index);
        },
      ),
    );
  }

  /// Product card widget
  Widget _buildProductCard(int index) {
    final hasOffer = index % 2 == 0;
    final imagePath = hasOffer ? 'assets/demo/product_1.png' : 'assets/demo/product_2.png';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EAE8)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Badge
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (hasOffer)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E36),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SALE',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'ACME Pharmaceuticals',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xB301060F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF1B71B), size: 12),
                          const SizedBox(width: 2),
                          const Text(
                            '4.9',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF01060F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Product Name
                  const Text(
                    'Paracetamol',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF191930),
                    ),
                  ),

                  const Spacer(),

                  // Price and Add to Bag Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '৳100-৳150',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF064E36),
                            ),
                          ),
                          const Text(
                            'MOQ 20 Box',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 8,
                              fontWeight: FontWeight.w400,
                              color: Color(0xB301060F),
                            ),
                          ),
                        ],
                      ),

                      // Add to Bag Button
                      Container(
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E36),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Add to Bag',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Brands horizontal list
  Widget _buildBrands() {
    final brands = [
      {'name': 'Incepta\nPharmaceu...', 'image': 'assets/demo/company_1.png'},
      {'name': 'ACME\nPharmaceu...', 'image': 'assets/demo/company_2.png'},
      {'name': 'Opsonin\nPharmaceu...', 'image': 'assets/demo/company_3.png'},
      {'name': 'Aristopharma\nPharmaceu...', 'image': 'assets/demo/company_4.png'},
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
          );
        },
      ),
    );
  }

  /// Offer timer widget
  Widget _buildOfferTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF064E36),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 15),
          const SizedBox(width: 3),
          const Text(
            '12:12:30',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

