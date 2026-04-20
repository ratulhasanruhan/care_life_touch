import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';
import '../models/review.dart';

class ProductReviewsController extends GetxController {
  ProductReviewsController({ReviewRepository? reviewRepository})
    : _reviewRepository = reviewRepository ?? Get.find<ReviewRepository>();

  final ReviewRepository _reviewRepository;

  final reviews = <Review>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;
  final productId = ''.obs;

  // Rating statistics
  final averageRating = 0.0.obs;
  final totalReviews = 0.obs;
  final ratingCounts = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _resolveArguments();
    loadReviews();
  }

  void _resolveArguments() {
    final args = Get.arguments;
    if (args is Map) {
      final id = args['productId']?.toString() ?? '';
      if (id.isNotEmpty) {
        productId.value = id;
      }
      return;
    }
    if (args is String && args.isNotEmpty) {
      productId.value = args;
    }
  }

  Future<void> loadReviews() async {
    if (productId.value.isEmpty) {
      errorMessage.value = 'Product not found for reviews.';
      reviews.clear();
      _calculateRatingStatistics();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final items = await _reviewRepository.getProductReviews(
        productId.value,
        limit: 50,
      );
      reviews.assignAll(items.map(_mapApiReview));
      _calculateRatingStatistics();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load product reviews', error, stackTrace);
      errorMessage.value = 'Failed to load reviews. Please try again.';
      reviews.clear();
      _calculateRatingStatistics();
    } finally {
      isLoading.value = false;
    }
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
  }) async {
    if (productId.value.isEmpty) {
      Get.snackbar('Error', 'Missing product information.');
      return;
    }
    if (comment.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your review comment.');
      return;
    }
    if (rating < 1 || rating > 5) {
      Get.snackbar('Error', 'Please select a rating between 1 and 5.');
      return;
    }

    isSubmitting.value = true;
    try {
      await _reviewRepository.createReview(
        productId: productId.value,
        rating: rating,
        comment: comment,
      );

      await loadReviews();

      Get.snackbar(
        'Success',
        'Your review has been submitted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to submit review', error, stackTrace);
      Get.snackbar(
        'Error',
        'Failed to submit review. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Review _mapApiReview(ReviewModel model) {
    final safeName = model.reviewerName.trim().isEmpty ? 'Anonymous' : model.reviewerName.trim();
    return Review(
      id: model.id,
      userName: safeName,
      reviewerImage: model.reviewerImage,
      rating: model.rating,
      comment: model.reviewText,
      date: model.createdAt == null ? '' : _formatDate(model.createdAt!),
      isVerifiedPurchase: model.isVerifiedPurchase ?? false,
      images: model.images ?? const <String>[],
      helpfulCount: model.helpfulCount ?? 0,
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}


