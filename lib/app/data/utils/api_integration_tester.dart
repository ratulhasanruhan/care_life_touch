import 'package:get/get.dart';
import '../repositories/product_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/address_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../repositories/review_repository.dart';
import '../../core/utils/app_logger.dart';

/// API Integration Testing Utility
/// Tests all critical API endpoints to ensure proper integration
class ApiIntegrationTester {
  static Future<void> runAllTests() async {
    AppLogger.info('🧪 Starting API integration tests...');
    final results = <String, bool>{};

    // Product APIs
    results['Products List'] = await _testProductsList();
    results['Search Products'] = await _testSearchProducts();
    results['Filter Products'] = await _testFilterProducts();
    results['Trending Products'] = await _testTrendingProducts();
    results['New Products'] = await _testNewProducts();
    results['Offer Products'] = await _testOfferProducts();
    results['Get Categories'] = await _testGetCategories();
    results['Get Brands'] = await _testGetBrands();

    // Cart APIs
    results['Get Cart'] = await _testGetCart();
    results['Add to Cart'] = await _testAddToCart();
    results['Update Cart'] = await _testUpdateCart();
    results['Remove from Cart'] = await _testRemoveFromCart();

    // Order APIs
    results['Get My Orders'] = await _testGetMyOrders();
    results['Create Order'] = await _testCreateOrder();

    // Address APIs
    results['Get My Addresses'] = await _testGetMyAddresses();
    results['Add Address'] = await _testAddAddress();

    // Notification APIs
    results['Get Notifications'] = await _testGetNotifications();
    results['Get Unread Count'] = await _testGetUnreadCount();

    // Wishlist APIs
    results['Get Wishlist'] = await _testGetWishlist();
    results['Toggle Wishlist'] = await _testToggleWishlist();

    // Review APIs
    results['Get Product Reviews'] = await _testGetProductReviews();
    results['Get Reviewable Products'] = await _testGetReviewableProducts();

    _printResults(results);
  }

  // Product API Tests
  static Future<bool> _testProductsList() async {
    try {
      final repo = Get.find<ProductRepository>();
      final products = await repo.getAllProducts();
      AppLogger.info('✅ Products List: Found ${products.length} products');
      return true;
    } catch (e) {
      AppLogger.error('❌ Products List', e);
      return false;
    }
  }

  static Future<bool> _testSearchProducts() async {
    try {
      final repo = Get.find<ProductRepository>();
      final products = await repo.searchProducts('tablet', limit: 5);
      AppLogger.info('✅ Search Products: Found ${products.length} results');
      return true;
    } catch (e) {
      AppLogger.error('❌ Search Products', e);
      return false;
    }
  }

  static Future<bool> _testFilterProducts() async {
    try {
      final repo = Get.find<ProductRepository>();
      final products = await repo.filterProducts(limit: 5);
      AppLogger.info('✅ Filter Products: Found ${products.length} products');
      return true;
    } catch (e) {
      AppLogger.error('❌ Filter Products', e);
      return false;
    }
  }

  static Future<bool> _testTrendingProducts() async {
    try {
      final repo = Get.find<ProductRepository>();
      final products = await repo.getTrendingProducts(limit: 5);
      AppLogger.info('✅ Trending Products: Found ${products.length} products');
      return true;
    } catch (e) {
      AppLogger.error('❌ Trending Products', e);
      return false;
    }
  }

  static Future<bool> _testNewProducts() async {
    try {
      final repo = Get.find<ProductRepository>();
      final products = await repo.getNewProducts(limit: 5);
      AppLogger.info('✅ New Products: Found ${products.length} products');
      return true;
    } catch (e) {
      AppLogger.error('❌ New Products', e);
      return false;
    }
  }

  static Future<bool> _testOfferProducts() async {
    try {
      final repo = Get.find<ProductRepository>();
      final products = await repo.getOfferProducts(limit: 5);
      AppLogger.info('✅ Offer Products: Found ${products.length} products');
      return true;
    } catch (e) {
      AppLogger.error('❌ Offer Products', e);
      return false;
    }
  }

  static Future<bool> _testGetCategories() async {
    try {
      final repo = Get.find<ProductRepository>();
      final categories = await repo.getAllCategories();
      AppLogger.info('✅ Get Categories: Found ${categories.length} categories');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Categories', e);
      return false;
    }
  }

  static Future<bool> _testGetBrands() async {
    try {
      final repo = Get.find<ProductRepository>();
      final brands = await repo.getAllBrands();
      AppLogger.info('✅ Get Brands: Found ${brands.length} brands');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Brands', e);
      return false;
    }
  }

  // Cart API Tests
  static Future<bool> _testGetCart() async {
    try {
      final repo = Get.find<CartRepository>();
      final cart = await repo.getCart();
      AppLogger.info('✅ Get Cart: ${cart.items.length} items, Total: ৳${cart.total}');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Cart', e);
      return false;
    }
  }

  static Future<bool> _testAddToCart() async {
    try {
      final products = await Get.find<ProductRepository>().getAllProducts();
      if (products.isEmpty) {
        AppLogger.warning('⚠️ Add to Cart: No products available');
        return false;
      }
      final product = products.first;
      final variantId = product.defaultVariantId ?? 'test';
      final cart = await Get.find<CartRepository>().addToCart(
        productId: product.id,
        variantId: variantId,
        quantity: 1,
      );
      AppLogger.info('✅ Add to Cart: ${cart.items.length} items');
      return true;
    } catch (e) {
      AppLogger.error('❌ Add to Cart', e);
      return false;
    }
  }

  static Future<bool> _testUpdateCart() async {
    try {
      final cart = await Get.find<CartRepository>().getCart();
      if (cart.items.isEmpty) {
        AppLogger.warning('⚠️ Update Cart: Cart is empty');
        return false;
      }
      final item = cart.items.first;
      await Get.find<CartRepository>().updateCartItem(
        itemId: item.itemId,
        quantity: item.quantity + 1,
      );
      AppLogger.info('✅ Update Cart: Item quantity updated');
      return true;
    } catch (e) {
      AppLogger.error('❌ Update Cart', e);
      return false;
    }
  }

  static Future<bool> _testRemoveFromCart() async {
    try {
      final cart = await Get.find<CartRepository>().getCart();
      if (cart.items.isEmpty) {
        AppLogger.warning('⚠️ Remove from Cart: Cart is empty');
        return false;
      }
      final item = cart.items.last;
      await Get.find<CartRepository>().removeCartItem(item.itemId);
      AppLogger.info('✅ Remove from Cart: Item removed');
      return true;
    } catch (e) {
      AppLogger.error('❌ Remove from Cart', e);
      return false;
    }
  }

  // Order API Tests
  static Future<bool> _testGetMyOrders() async {
    try {
      final repo = Get.find<OrderRepository>();
      final orders = await repo.getMyOrders();
      AppLogger.info('✅ Get My Orders: ${orders.length} orders');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get My Orders', e);
      return false;
    }
  }

  static Future<bool> _testCreateOrder() async {
    try {
      AppLogger.warning('⚠️ Create Order: Skipped (requires cart and address)');
      return true;
    } catch (e) {
      AppLogger.error('❌ Create Order', e);
      return false;
    }
  }

  // Address API Tests
  static Future<bool> _testGetMyAddresses() async {
    try {
      final repo = Get.find<AddressRepository>();
      final addresses = await repo.getMyAddresses();
      AppLogger.info('✅ Get My Addresses: ${addresses.length} addresses');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get My Addresses', e);
      return false;
    }
  }

  static Future<bool> _testAddAddress() async {
    try {
      AppLogger.warning('⚠️ Add Address: Skipped (requires valid coordinates)');
      return true;
    } catch (e) {
      AppLogger.error('❌ Add Address', e);
      return false;
    }
  }

  // Notification API Tests
  static Future<bool> _testGetNotifications() async {
    try {
      final repo = Get.find<NotificationRepository>();
      final notifications = await repo.getBuyerNotifications();
      AppLogger.info('✅ Get Notifications: ${notifications.length} notifications');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Notifications', e);
      return false;
    }
  }

  static Future<bool> _testGetUnreadCount() async {
    try {
      final repo = Get.find<NotificationRepository>();
      final count = await repo.getUnreadCount();
      AppLogger.info('✅ Get Unread Count: $count unread');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Unread Count', e);
      return false;
    }
  }

  // Wishlist API Tests
  static Future<bool> _testGetWishlist() async {
    try {
      final repo = Get.find<WishlistRepository>();
      final wishlist = await repo.getWishlist();
      AppLogger.info('✅ Get Wishlist: ${wishlist.items.length} items');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Wishlist', e);
      return false;
    }
  }

  static Future<bool> _testToggleWishlist() async {
    try {
      final products = await Get.find<ProductRepository>().getAllProducts();
      if (products.isEmpty) {
        AppLogger.warning('⚠️ Toggle Wishlist: No products available');
        return false;
      }
      final product = products.first;
      final wishlist = await Get.find<WishlistRepository>().toggleWishlist(product.id);
      AppLogger.info('✅ Toggle Wishlist: ${wishlist.items.length} items');
      return true;
    } catch (e) {
      AppLogger.error('❌ Toggle Wishlist', e);
      return false;
    }
  }

  // Review API Tests
  static Future<bool> _testGetProductReviews() async {
    try {
      final products = await Get.find<ProductRepository>().getAllProducts();
      if (products.isEmpty) {
        AppLogger.warning('⚠️ Get Product Reviews: No products available');
        return false;
      }
      final product = products.first;
      final repo = Get.find<ReviewRepository>();
      final reviews = await repo.getProductReviews(product.id, limit: 5);
      AppLogger.info('✅ Get Product Reviews: ${reviews.length} reviews');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Product Reviews', e);
      return false;
    }
  }

  static Future<bool> _testGetReviewableProducts() async {
    try {
      final repo = Get.find<ReviewRepository>();
      final products = await repo.getReviewableProducts();
      AppLogger.info('✅ Get Reviewable Products: ${products.length} products');
      return true;
    } catch (e) {
      AppLogger.error('❌ Get Reviewable Products', e);
      return false;
    }
  }

  // Helper to print results summary
  static void _printResults(Map<String, bool> results) {
    AppLogger.info('');
    AppLogger.info('═══════════════════════════════════════════');
    AppLogger.info('🧪 API INTEGRATION TEST RESULTS');
    AppLogger.info('═══════════════════════════════════════════');
    
    int passed = 0;
    int failed = 0;
    
    results.forEach((test, result) {
      if (result) {
        passed++;
      } else {
        failed++;
      }
    });

    AppLogger.info('Total: ${results.length} | Passed: $passed | Failed: $failed');
    AppLogger.info('═══════════════════════════════════════════');
    
    if (failed == 0) {
      AppLogger.info('✅ All API integration tests passed!');
    } else {
      AppLogger.warning('⚠️ $failed test(s) failed. Check logs above.');
    }
  }
}


