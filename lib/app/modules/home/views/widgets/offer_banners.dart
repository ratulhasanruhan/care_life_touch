import 'package:flutter/material.dart';

/// Offer Banner Widget
class OfferBanner extends StatelessWidget {
  final String imagePath;
  final String? text;
  final VoidCallback? onTap;

  const OfferBanner({
    super.key,
    required this.imagePath,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: text != null
            ? Center(
                child: Text(
                  text!,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
      ),
    );
  }
}

/// Offer Banners Carousel Widget
class OfferBannersCarousel extends StatefulWidget {
  final List<Map<String, String>> banners;

  const OfferBannersCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<OfferBannersCarousel> createState() => _OfferBannersCarouselState();
}

class _OfferBannersCarouselState extends State<OfferBannersCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banners
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: OfferBanner(
                  imagePath: banner['image']!,
                  text: banner['text'],
                  onTap: () {
                    // Handle banner tap
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => Container(
              width: index == _currentPage ? 20 : 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? const Color(0xFF064E36)
                    : const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

