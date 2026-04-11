import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/review_repository.dart';

class WriteReviewController extends GetxController {
  WriteReviewController({
    ReviewRepository? reviewRepository,
    AuthRepository? authRepository,
  }) : _reviewRepository = reviewRepository ?? Get.find<ReviewRepository>(),
       _authRepository = authRepository ?? Get.find<AuthRepository>();

  final ReviewRepository _reviewRepository;
  final AuthRepository _authRepository;
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
        Get.snackbar(
          'Limit reached',
          'You can upload up to 5 images.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      selectedImages.addAll(files.take(remaining).map((f) => File(f.path)));
    } catch (error, stackTrace) {
      AppLogger.error('Failed to pick review images', error, stackTrace);
      Get.snackbar(
        'Failed',
        'Could not pick images. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    if (productId.value.isEmpty || orderId.value.isEmpty || variantId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Missing product or order details for review.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (rating.value < 1 || rating.value > 5) {
      Get.snackbar(
        'Validation',
        'Please select a rating.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Please write a review title.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (commentController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Please write your comment.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Review submitted successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to submit review', error, stackTrace);
      Get.snackbar(
        'Failed',
        'Could not submit your review. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
}
