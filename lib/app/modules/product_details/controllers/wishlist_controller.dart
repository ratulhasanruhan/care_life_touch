import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/wishlist_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

class WishlistController extends GetxController {
  final WishlistRepository _wishlistRepository;

  WishlistController({WishlistRepository? wishlistRepository})
    : _wishlistRepository =
          wishlistRepository ?? Get.find<WishlistRepository>();

  final wishlistItems = <WishlistItem>[].obs;
  final isLoading = false.obs;
  final isMutating = false.obs;
  final errorMessage = ''.obs;
  final wishlistedProductIds = <String>{}.obs;

  int get itemCount => wishlistItems.length;
  bool get isEmpty => wishlistItems.isEmpty;

  Future<void> loadWishlist() async {
    isLoading.value = true;
    try {
      errorMessage.value = '';
      final snapshot = await _wishlistRepository.getWishlist();
      wishlistItems.value = snapshot.items;
      _updateWishlistedIds();
    } catch (e) {
      AppLogger.error('Failed to load wishlist', e);
      errorMessage.value = _resolveError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleWishlist(String productId) async {
    isMutating.value = true;
    errorMessage.value = '';
    try {
      final snapshot = await _wishlistRepository.toggleWishlist(productId);
      wishlistItems.value = snapshot.items;
      _updateWishlistedIds();
      _showSuccess(
        wishlistedProductIds.contains(productId)
            ? 'Added to wishlist'
            : 'Removed from wishlist',
      );
    } catch (e) {
      AppLogger.error('Toggle wishlist failed', e);
      errorMessage.value = _resolveError(e);
      _showError(_resolveError(e));
    } finally {
      isMutating.value = false;
    }
  }

  bool isInWishlist(String productId) {
    return wishlistedProductIds.contains(productId);
  }

  Future<void> removeFromWishlist(String productId) async {
    isMutating.value = true;
    try {
      errorMessage.value = '';
      await _wishlistRepository.removeFromWishlist(productId);
      wishlistItems.removeWhere((item) => item.productId == productId);
      _updateWishlistedIds();
      _showSuccess('Removed from wishlist');
    } catch (e) {
      AppLogger.error('Remove from wishlist failed', e);
      errorMessage.value = _resolveError(e);
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> clearWishlist() async {
    isMutating.value = true;
    try {
      errorMessage.value = '';
      await _wishlistRepository.clearWishlist();
      wishlistItems.clear();
      wishlistedProductIds.clear();
      _showSuccess('Wishlist cleared');
    } catch (e) {
      AppLogger.error('Clear wishlist failed', e);
      errorMessage.value = _resolveError(e);
    } finally {
      isMutating.value = false;
    }
  }

  void _updateWishlistedIds() {
    wishlistedProductIds
      ..clear()
      ..addAll(wishlistItems.map((item) => item.productId));
  }

  String _resolveError(dynamic error) {
    if (error is Exception) {
      return error.toString();
    }
    return 'An error occurred. Please try again.';
  }

  void _showSuccess(String message) {
    AppLogger.info(message);
    // Consider adding toast notification here
  }

  void _showError(String message) {
    AppLogger.error('Error', message);
    // Consider adding toast notification here
  }
}
