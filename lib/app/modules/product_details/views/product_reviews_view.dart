import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/product_reviews_controller.dart';
import '../models/review.dart';

class ProductReviewsView extends GetView<ProductReviewsController> {
  const ProductReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'Ratings & Reviews',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Rating Summary Section
          _buildRatingSummary(),

          const Divider(height: 1, color: Color(0xFFE8EAE8)),

          // Reviews List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState();
              }

              if (controller.reviews.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: controller.reviews.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 32, color: Color(0xFFE8EAE8)),
                itemBuilder: (context, index) {
                  final review = controller.reviews[index];
                  return _buildReviewItem(review);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Obx(() {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Rating
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        controller.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF01060F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating: controller.averageRating.value,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Color(0xFFF1B71B)),
                        itemCount: 5,
                        itemSize: 20,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.totalReviews} Reviews',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xB301060F),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 32),

                // Rating Breakdown
                Expanded(
                  flex: 3,
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      final count = controller.ratingCounts[star] ?? 0;
                      final percentage = controller.totalReviews > 0
                          ? (count / controller.totalReviews.value) * 100
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              '$star',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF01060F),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFFF1B71B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: const Color(0xFFE8EAE8),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF064E36),
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 32,
                              child: Text(
                                count.toString(),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xB301060F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviewer Info
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFF6F6F6),
              child: Text(
                review.userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF064E36),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF01060F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: review.rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Color(0xFFF1B71B)),
                        itemCount: 5,
                        itemSize: 14,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review.date,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xB301060F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (review.isVerifiedPurchase)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1A064E36),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF064E36),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Review Text
        if (review.comment.isNotEmpty)
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
              color: Color(0xB301060F),
            ),
          ),

        // Review Images (if any)
        if (review.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: review.images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _buildReviewImage(review.images[index]),
                );
              },
            ),
          ),
        ],

        // Helpful Button
        const SizedBox(height: 12),
        Row(
          children: [
            InkWell(
              onTap: () => controller.toggleHelpful(review.id),
              child: Row(
                children: [
                  Icon(
                    review.isHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16,
                    color: review.isHelpful
                        ? const Color(0xFF064E36)
                        : const Color(0xB301060F),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Helpful (${review.helpfulCount})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: review.isHelpful
                          ? const Color(0xFF064E36)
                          : const Color(0xB301060F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF01060F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to review this product',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xB301060F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFB00020)),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xB301060F),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: controller.loadReviews,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewImage(String path) {
    final isRemote = path.startsWith('http://') || path.startsWith('https://');
    if (isRemote) {
      return Image.network(
        path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    return Image.asset(
      path,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF6F6F6),
      child: const Icon(Icons.image, color: Color(0xFFA2A8AF)),
    );
  }
}
