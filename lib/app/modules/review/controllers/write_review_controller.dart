import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/helpers.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/review_repository.dart';

class WriteReviewController extends GetxController {
  WriteReviewController({
    ReviewRepository? reviewRepository,
    AuthRepository? authRepository,
    StorageService? storageService,
  }) : _reviewRepository = reviewRepository ?? Get.find<ReviewRepository>(),
       _authRepository = authRepository ?? Get.find<AuthRepository>(),
       _storage = storageService ?? Get.find<StorageService>();

  final ReviewRepository _reviewRepository;
  final AuthRepository _authRepository;
  final StorageService _storage;
  final ImagePicker _picker = ImagePicker();

  final productId = ''.obs;
  final orderId = ''.obs;
  final variantId = ''.obs;

  final productName = 'Product'.obs;
  final brandName = ''.obs;
  final quantityText = ''.obs;
  final priceText = ''.obs;
  final oldPriceText = ''.obs;
  final imageUrl = ''.obs;
  final reviewerName = 'Guest User'.obs;
  final reviewerPhone = ''.obs;
  final reviewerImage = ''.obs;
  final canSubmitReview = true.obs;

  final rating = 0.obs;
  final isSubmitting = false.obs;
  final isPickingImages = false.obs;
  final selectedImages = <File>[].obs;

  final titleController = TextEditingController();
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _resolveArguments();
    _loadReviewerInfo();
  }

  @override
  void onClose() {
    titleController.dispose();
    commentController.dispose();
    super.onClose();
  }

  Future<void> pickImages() async {
    if (isPickingImages.value) return;
    try {
      isPickingImages.value = true;
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;

      final remaining = 5 - selectedImages.length;
      if (remaining <= 0) {
        AppHelpers.showErrorSnackbar(message: 'You can upload up to 5 images.', title: 'Limit reached');
        return;
      }

      selectedImages.addAll(files.take(remaining).map((f) => File(f.path)));
    } catch (error, stackTrace) {
      AppLogger.error('Failed to pick review images', error, stackTrace);
      AppHelpers.showErrorSnackbar(message: 'Could not pick images. Please try again.', title: 'Failed');
    } finally {
      isPickingImages.value = false;
    }
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= selectedImages.length) return;
    selectedImages.removeAt(index);
  }

  void setRating(int value) {
    rating.value = value.clamp(1, 5);
  }

  Future<void> submit() async {
    if (!canSubmitReview.value) {
      AppHelpers.showErrorSnackbar(
        message: 'You can submit a review for this product only one time after order completion.',
        title: 'Already reviewed',
      );
      return;
    }

    if (productId.value.isEmpty || orderId.value.isEmpty || variantId.value.isEmpty) {
      AppHelpers.showErrorSnackbar(message: 'Missing product or order details for review.');
      return;
    }
    if (rating.value < 1 || rating.value > 5) {
      AppHelpers.showErrorSnackbar(message: 'Please select a rating.', title: 'Validation');
      return;
    }
    if (titleController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar(message: 'Please write a review title.', title: 'Validation');
      return;
    }
    if (commentController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar(message: 'Please write your comment.', title: 'Validation');
      return;
    }

    try {
      isSubmitting.value = true;

      final imageUrls = <String>[];
      for (final file in selectedImages) {
        final url = await _authRepository.uploadImage(file);
        if (url.trim().isNotEmpty) {
          imageUrls.add(url.trim());
        }
      }

      await _reviewRepository.createReview(
        productId: productId.value,
        orderId: orderId.value,
        variantId: variantId.value,
        rating: rating.value.toDouble(),
        title: titleController.text.trim(),
        comment: commentController.text.trim(),
        images: imageUrls,
      );

      canSubmitReview.value = false;
      Get.back(result: true);
      AppHelpers.showSuccessSnackbar(message: 'Review submitted successfully.');
    } catch (error, stackTrace) {
      AppLogger.error('Failed to submit review', error, stackTrace);
      if (_isDuplicateReviewError(error)) {
        canSubmitReview.value = false;
        AppHelpers.showErrorSnackbar(
          message: 'You have already submitted a review for this product.',
          title: 'Already reviewed',
        );
        return;
      }
      AppHelpers.showErrorSnackbar(message: 'Could not submit your review. Please try again.', title: 'Failed');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resolveArguments() {
    final args = Get.arguments;
    if (args is! Map) return;

    productId.value = args['productId']?.toString() ?? '';
    orderId.value = args['orderId']?.toString() ?? '';
    variantId.value = args['variantId']?.toString() ?? '';
    canSubmitReview.value = args['canReview'] != false;

    final item = _asMap(args['item']);
    if (item == null) return;

    final product = _asMap(item['product']);
    productName.value =
        _firstNonEmpty([
          item['productName'],
          product?['name'],
          product?['title'],
          product?['productName'],
        ]) ??
        'Product';

    brandName.value =
        _firstNonEmpty([
          item['brandName'],
          product?['brandName'],
          product?['manufacturer'],
          product?['company'],
        ]) ??
        '';

    final quantity = item['quantity'];
    if (quantity != null && quantity.toString().trim().isNotEmpty) {
      quantityText.value = 'Quantity: ${quantity.toString()}';
    }

    final price = _toDouble(item['price']) ?? _toDouble(item['finalPrice']);
    if (price != null) {
      priceText.value = '৳${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}';
    }

    final oldPrice = _toDouble(item['regularPrice']) ?? _toDouble(item['mrp']);
    if (oldPrice != null && (price == null || oldPrice > price)) {
      oldPriceText.value = '৳${oldPrice.toStringAsFixed(oldPrice % 1 == 0 ? 0 : 2)}';
    }

    imageUrl.value =
        _firstNonEmpty([
          item['image'],
          product?['thumbnail'],
          product?['image'],
          _firstImage(product?['images']),
        ]) ??
        '';
  }

  Future<void> _loadReviewerInfo() async {
    final localUser = _storage.getUser();
    if (localUser != null) {
      _applyReviewer(localUser);
    }

    try {
      final freshUser = await _authRepository.accessMe();
      _applyReviewer(freshUser);
      if (freshUser.isNotEmpty) {
        await _storage.saveUser(freshUser);
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to refresh reviewer profile', error, stackTrace);
    }
  }

  void _applyReviewer(Map<String, dynamic> user) {
    final name = _firstNonEmpty([
      user['name'],
      user['fullName'],
      user['userName'],
      user['shopName'],
    ]);
    final phone = _firstNonEmpty([user['phone'], user['mobile']]);
    final image = _firstNonEmpty([
      user['profileImage'],
      user['profile_image'],
      user['avatar'],
      user['image'],
    ]);

    if (name != null) reviewerName.value = name;
    reviewerPhone.value = phone ?? '';
    reviewerImage.value = image ?? '';
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String? _firstImage(dynamic images) {
    if (images is! List || images.isEmpty) return null;
    final first = images.first;
    if (first is String && first.trim().isNotEmpty) return first.trim();
    if (first is Map) {
      final url = first['url']?.toString().trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  bool _isDuplicateReviewError(Object error) {
    if (error is ApiException) {
      final normalized = error.message.toLowerCase();
      return normalized.contains('already') &&
          normalized.contains('review');
    }

    final normalized = error.toString().toLowerCase();
    return normalized.contains('already') && normalized.contains('review');
  }
}
