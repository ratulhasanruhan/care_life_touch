import 'package:get/get.dart';
import '../models/review_model.dart';
import '../providers/api_provider.dart';
import '../../core/utils/app_logger.dart';

class ReviewRepository {
  ReviewRepository({ApiProvider? apiProvider})
    : _api =
          apiProvider ??
          (Get.isRegistered<ApiProvider>()
              ? Get.find<ApiProvider>()
              : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<Map<String, dynamic>> createReview({
    required String productId,
    required double rating,
    String? orderId,
    String? variantId,
    String? title,
    required String comment,
    List<String>? images,
  }) async {
    final trimmedOrderId = orderId?.trim() ?? '';
    final trimmedVariantId = variantId?.trim() ?? '';
    final trimmedTitle = title?.trim() ?? '';

    final imagePayload = images == null
        ? null
        : images
              .map((url) => url.trim())
              .where((url) => url.isNotEmpty)
              .map((url) => {'url': url})
              .toList();

    final response = await _api.postData(
      '/create-review',
      body: {
        'productId': productId,
        'rating': rating,
        if (trimmedOrderId.isNotEmpty) 'orderId': trimmedOrderId,
        if (trimmedVariantId.isNotEmpty) 'variantId': trimmedVariantId,
        if (trimmedTitle.isNotEmpty) 'title': trimmedTitle,
        'comment': comment.trim(),
        if (imagePayload != null && imagePayload.isNotEmpty)
          'images': imagePayload,
      },
    );
    return _toMap(response) ?? {};
  }

  Future<List<ReviewModel>> getProductReviews(
    String productId, {
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (sortBy != null && sortBy.isNotEmpty) 'sort': sortBy,
    };
    final response = await _api.getData(
      '/get-product-reviews/$productId',
      query: query.isEmpty ? null : query,
    );
    return _extractReviews(response);
  }

  Future<List<ReviewModel>> getMyReviews({int? page, int? limit}) async {
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
    final response = await _api.getData(
      '/my-reviews',
      query: query.isEmpty ? null : query,
    );
    return _extractReviews(response);
  }

  Future<List<Map<String, dynamic>>> getReviewableProducts() async {
    final response = await _api.getData('/reviewable-products');
    final map = _toMap(response);
    if (map == null) return [];

    final productsRaw = map['data'] ?? map['products'] ?? map['items'] ?? [];
    if (productsRaw is List) {
      return productsRaw.map(_toMap).whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  List<ReviewModel> _extractReviews(dynamic response) {
    final map = _toMap(response);
    AppLogger.info('📥 Raw API Response: $response');
    AppLogger.info('🔍 Parsed Map: $map');
    
    if (map == null) return [];

    final reviewsRaw =
        map['data'] ?? map['reviews'] ?? map['items'] ?? map['result'] ?? [];
    AppLogger.info('📋 Reviews Raw Data: $reviewsRaw');
    
    if (reviewsRaw is List) {
      final parsed = reviewsRaw
          .map((r) => _toMap(r))
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
      AppLogger.info('✅ Parsed ${parsed.length} reviews from API response');
      return parsed;
    }
    return [];
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}
