import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Offer Banners Carousel Widget
class OfferBannersCarousel extends StatefulWidget {
  final List<String> banners;

  const OfferBannersCarousel({super.key, required this.banners});

  @override
  State<OfferBannersCarousel> createState() => _OfferBannersCarouselState();
}

class _OfferBannersCarouselState extends State<OfferBannersCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
            viewportFraction: 0.88,
            autoPlay: true,
            enableInfiniteScroll: false,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.banners.map((banner) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: AssetImage(banner),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Dots Indicator
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SmoothPageIndicator(
            controller: PageController(initialPage: _currentIndex),
            count: widget.banners.length,
            effect: const ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              spacing: 4,
              activeDotColor: Color(0xFF064E36),
              dotColor: Color(0xFFDDDDDD),
            ),
          ),
        ),
      ],
    );
  }
}
