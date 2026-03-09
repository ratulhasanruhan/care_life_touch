import 'dart:ui';

import 'package:get/get.dart';
import '../models/review.dart';

class ProductReviewsController extends GetxController {
  final reviews = <Review>[].obs;
  final isLoading = false.obs;

  // Rating statistics
  final averageRating = 0.0.obs;
  final totalReviews = 0.obs;
  final ratingCounts = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReviews();
  }

  void _loadReviews() {
    isLoading.value = true;

    // Simulate API call - Replace with actual API call
    Future.delayed(const Duration(milliseconds: 500), () {
      // Demo data
      reviews.value = [
        Review(
          id: '1',
          userName: 'John Doe',
          rating: 5.0,
          comment: 'Excellent product! Works exactly as described. Very effective for pain relief.',
          date: 'Feb 28, 2024',
          isVerifiedPurchase: true,
          helpfulCount: 12,
        ),
        Review(
          id: '2',
          userName: 'Jane Smith',
          rating: 4.0,
          comment: 'Good quality medicine. Fast delivery and well packaged.',
          date: 'Feb 25, 2024',
          isVerifiedPurchase: true,
          helpfulCount: 8,
        ),
        Review(
          id: '3',
          userName: 'Mike Johnson',
          rating: 5.0,
          comment: 'Very satisfied with the purchase. Will order again.',
          date: 'Feb 20, 2024',
          isVerifiedPurchase: false,
          helpfulCount: 5,
        ),
        Review(
          id: '4',
          userName: 'Sarah Williams',
          rating: 4.5,
          comment: 'Great product at a reasonable price. Highly recommended!',
          date: 'Feb 18, 2024',
          isVerifiedPurchase: true,
          helpfulCount: 15,
        ),
        Review(
          id: '5',
          userName: 'David Brown',
          rating: 3.0,
          comment: 'Product is okay, but delivery took longer than expected.',
          date: 'Feb 15, 2024',
          isVerifiedPurchase: true,
          helpfulCount: 3,
        ),
      ];

      _calculateRatingStatistics();
      isLoading.value = false;
    });
  }

  void _calculateRatingStatistics() {
    if (reviews.isEmpty) {
      averageRating.value = 0;
      totalReviews.value = 0;
      ratingCounts.value = {};
      return;
    }

    // Calculate average rating
    double sum = 0;
    for (var review in reviews) {
      sum += review.rating;
    }
    averageRating.value = sum / reviews.length;
    totalReviews.value = reviews.length;

    // Count ratings by star
    ratingCounts.value = {
      5: reviews.where((r) => r.rating >= 4.5).length,
      4: reviews.where((r) => r.rating >= 3.5 && r.rating < 4.5).length,
      3: reviews.where((r) => r.rating >= 2.5 && r.rating < 3.5).length,
      2: reviews.where((r) => r.rating >= 1.5 && r.rating < 2.5).length,
      1: reviews.where((r) => r.rating < 1.5).length,
    };
  }

  void toggleHelpful(String reviewId) {
    final index = reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      reviews[index].isHelpful = !reviews[index].isHelpful;
      reviews.refresh();
    }
  }

  void submitReview({
    required double rating,
    required String comment,
  }) {
    // Create new review
    final newReview = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Current User', // Replace with actual user name
      rating: rating,
      comment: comment,
      date: _formatDate(DateTime.now()),
      isVerifiedPurchase: true,
      helpfulCount: 0,
    );

    // Add to beginning of list
    reviews.insert(0, newReview);

    // Recalculate statistics
    _calculateRatingStatistics();

    // Show success message
    Get.snackbar(
      'Success',
      'Your review has been submitted',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF064E36),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
    );

    // TODO: Send review to API
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}


