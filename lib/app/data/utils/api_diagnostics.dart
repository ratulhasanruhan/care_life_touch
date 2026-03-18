import 'package:get/get.dart';

import '../providers/api_provider.dart';
import '../../core/utils/app_logger.dart';

/// Quick API diagnostics utility - helps debug API integration issues
class ApiDiagnostics {
  static Future<void> testAllEndpoints() async {
    final api = Get.find<ApiProvider>();
    
    AppLogger.info('=== Testing All API Endpoints ===');
    
    // ============ PRODUCTS ENDPOINTS ============
    AppLogger.info('--- Testing Product Endpoints ---');
    
    // Test 1: All Products
    try {
      await api.getData('/products');
      AppLogger.success('✓ /products - OK');
    } catch (e) {
      AppLogger.error('✗ /products FAILED', e);
    }

    // Test 2: Product Details
    try {
      // Note: Replace with actual product slug if available
      await api.getData('/product-details/sample-slug');
      AppLogger.success('✓ /product-details/:slug - OK');
    } catch (e) {
      AppLogger.debug('⚠ /product-details/:slug - Expected failure (no sample slug)');
    }

    // Test 3: Related Products
    try {
      await api.getData('/related-products/sample-slug/related');
      AppLogger.success('✓ /related-products/:slug/related - OK');
    } catch (e) {
      AppLogger.debug('⚠ /related-products/:slug/related - Expected failure (no sample slug)');
    }

    // Test 4: Discounted Products
    try {
      await api.getData('/discounted-products');
      AppLogger.success('✓ /discounted-products - OK');
    } catch (e) {
      AppLogger.error('✗ /discounted-products FAILED', e);
    }

    // Test 5: Trending Products
    try {
      final trending = await api.getData('/trending-products', query: {'limit': 5});
      AppLogger.success('✓ /trending-products - OK');
      if (trending is Map) {
        final keys = (trending as Map).keys.toList();
        AppLogger.debug('Response keys: $keys');
      }
    } catch (e) {
      AppLogger.error('✗ /trending-products FAILED', e);
    }

    // Test 6: New Products
    try {
      await api.getData('/new-products', query: {'limit': 5});
      AppLogger.success('✓ /new-products - OK');
    } catch (e) {
      AppLogger.error('✗ /new-products FAILED', e);
    }

    // Test 7: Offer Products
    try {
      await api.getData('/offer-products', query: {'limit': 5, 'minDiscount': 1});
      AppLogger.success('✓ /offer-products - OK');
    } catch (e) {
      AppLogger.error('✗ /offer-products FAILED', e);
    }

    // Test 8: Search Products
    try {
      await api.getData('/search', query: {'q': 'test', 'limit': 5});
      AppLogger.success('✓ /search - OK');
    } catch (e) {
      AppLogger.error('✗ /search FAILED', e);
    }

    // Test 9: Products Filter Options
    try {
      await api.getData('/products-filter-options');
      AppLogger.success('✓ /products-filter-options - OK');
    } catch (e) {
      AppLogger.error('✗ /products-filter-options FAILED', e);
    }

    // ============ CATEGORIES & BRANDS ENDPOINTS ============
    AppLogger.info('--- Testing Categories & Brands Endpoints ---');
    
    // Test 10: All Categories
    try {
      final categories = await api.getData('/get-all-categories');
      AppLogger.success('✓ /get-all-categories - OK');
      if (categories is Map) {
        final keys = (categories as Map).keys.toList();
        AppLogger.debug('Response keys: $keys');
      }
    } catch (e) {
      AppLogger.error('✗ /get-all-categories FAILED', e);
    }

    // Test 11: All Sub Categories
    try {
      await api.getData('/get-all-sub-categories');
      AppLogger.success('✓ /get-all-sub-categories - OK');
    } catch (e) {
      AppLogger.error('✗ /get-all-sub-categories FAILED', e);
    }

    // Test 12: All Brands
    try {
      final brands = await api.getData('/get-all-brands');
      AppLogger.success('✓ /get-all-brands - OK');
      if (brands is Map) {
        final keys = (brands as Map).keys.toList();
        AppLogger.debug('Response keys: $keys');
      }
    } catch (e) {
      AppLogger.error('✗ /get-all-brands FAILED', e);
    }

    // ============ CART ENDPOINTS ============
    AppLogger.info('--- Testing Cart Endpoints ---');
    
    // Test 13: Get Cart
    try {
      await api.getData('/cart');
      AppLogger.success('✓ /cart - OK');
    } catch (e) {
      AppLogger.error('✗ /cart FAILED', e);
    }

    // Test 14: Add to Cart (POST - requires auth)
    try {
      await api.postData(
        '/cart-add',
        body: {
          'productId': 'sample-id',
          'variantId': 'sample-variant',
          'quantity': 1,
        },
      );
      AppLogger.success('✓ /cart-add - OK');
    } catch (e) {
      AppLogger.debug('⚠ /cart-add - Expected to fail (requires auth & valid product)');
    }

    // Test 15: Update Cart (PUT - requires auth)
    try {
      await api.putData(
        '/cart-update',
        body: {
          'itemId': 'sample-item',
          'quantity': 1,
        },
      );
      AppLogger.success('✓ /cart-update - OK');
    } catch (e) {
      AppLogger.debug('⚠ /cart-update - Expected to fail (requires auth & valid item)');
    }

    // Test 16: Remove from Cart (DELETE - requires auth)
    try {
      await api.deleteData('/cart-remove/sample-item');
      AppLogger.success('✓ /cart-remove/:itemId - OK');
    } catch (e) {
      AppLogger.debug('⚠ /cart-remove/:itemId - Expected to fail (requires auth & valid item)');
    }

    // Test 17: Clear Cart (DELETE - requires auth)
    try {
      await api.deleteData('/cart-clear');
      AppLogger.success('✓ /cart-clear - OK');
    } catch (e) {
      AppLogger.debug('⚠ /cart-clear - Expected to fail (requires auth)');
    }

    // ============ WISHLIST ENDPOINTS ============
    AppLogger.info('--- Testing Wishlist Endpoints ---');
    
    // Test 18: Get Wishlist
    try {
      await api.getData('/wishlist');
      AppLogger.success('✓ /wishlist - OK');
    } catch (e) {
      AppLogger.error('✗ /wishlist FAILED', e);
    }

    // Test 19: Wishlist Toggle (POST - requires auth)
    try {
      await api.postData(
        '/wishlist-toggle',
        body: {'productId': 'sample-id'},
      );
      AppLogger.success('✓ /wishlist-toggle - OK');
    } catch (e) {
      AppLogger.debug('⚠ /wishlist-toggle - Expected to fail (requires auth & valid product)');
    }

    // ============ ORDER ENDPOINTS ============
    AppLogger.info('--- Testing Order Endpoints ---');
    
    // Test 20: My Orders
    try {
      await api.getData('/my-orders');
      AppLogger.success('✓ /my-orders - OK');
    } catch (e) {
      AppLogger.error('✗ /my-orders FAILED', e);
    }

    // Test 21: Single Order
    try {
      await api.getData('/single-order/sample-id');
      AppLogger.success('✓ /single-order/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /single-order/:id - Expected to fail (no sample order)');
    }

    // Test 22: Create Order (POST - requires auth)
    try {
      await api.postData(
        '/create-order',
        body: {
          'items': [],
          'addressId': 'sample-address',
          'deliveryShift': 'morning',
          'paymentMethod': 'cod',
        },
      );
      AppLogger.success('✓ /create-order - OK');
    } catch (e) {
      AppLogger.debug('⚠ /create-order - Expected to fail (requires auth & valid data)');
    }

    // Test 23: Cancel Order (PATCH - requires auth)
    try {
      await api.patchData(
        '/cancel-order/sample-id',
        body: {'reason': 'Changed mind'},
      );
      AppLogger.success('✓ /cancel-order/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /cancel-order/:id - Expected to fail (requires auth & valid order)');
    }

    // Test 24: Return Order (PATCH - requires auth)
    try {
      await api.patchData(
        '/return-order/sample-id',
        body: {'reason': 'Defective'},
      );
      AppLogger.success('✓ /return-order/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /return-order/:id - Expected to fail (requires auth & valid order)');
    }

    // ============ REVIEWS ENDPOINTS ============
    AppLogger.info('--- Testing Review Endpoints ---');
    
    // Test 25: Public Reviews
    try {
      await api.getData('/public-reviews');
      AppLogger.success('✓ /public-reviews - OK');
    } catch (e) {
      AppLogger.error('✗ /public-reviews FAILED', e);
    }

    // Test 26: Get Product Reviews
    try {
      await api.getData('/get-product-reviews/sample-id');
      AppLogger.success('✓ /get-product-reviews/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /get-product-reviews/:id - Expected to fail (no sample product)');
    }

    // Test 27: My Reviews
    try {
      await api.getData('/my-reviews');
      AppLogger.success('✓ /my-reviews - OK');
    } catch (e) {
      AppLogger.error('✗ /my-reviews FAILED', e);
    }

    // Test 28: Reviewable Products
    try {
      await api.getData('/reviewable-products');
      AppLogger.success('✓ /reviewable-products - OK');
    } catch (e) {
      AppLogger.error('✗ /reviewable-products FAILED', e);
    }

    // Test 29: Create Review (POST - requires auth)
    try {
      await api.postData(
        '/create-review',
        body: {
          'productId': 'sample-id',
          'rating': 5,
          'comment': 'Great product!',
        },
      );
      AppLogger.success('✓ /create-review - OK');
    } catch (e) {
      AppLogger.debug('⚠ /create-review - Expected to fail (requires auth & valid product)');
    }

    // ============ NOTIFICATION ENDPOINTS ============
    AppLogger.info('--- Testing Notification Endpoints ---');
    
    // Test 30: Get Buyer Notifications
    try {
      await api.getData('/get-buyer-notifications');
      AppLogger.success('✓ /get-buyer-notifications - OK');
    } catch (e) {
      AppLogger.error('✗ /get-buyer-notifications FAILED', e);
    }

    // Test 31: Unread Notification Count
    try {
      await api.getData('/unread-notification-count');
      AppLogger.success('✓ /unread-notification-count - OK');
    } catch (e) {
      AppLogger.error('✗ /unread-notification-count FAILED', e);
    }

    // Test 32: Mark Notification Read (PATCH - requires auth)
    try {
      await api.patchData('/mark-notification-read/sample-id');
      AppLogger.success('✓ /mark-notification-read/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /mark-notification-read/:id - Expected to fail (requires auth)');
    }

    // Test 33: Mark All Notifications Read (PATCH - requires auth)
    try {
      await api.patchData('/mark-all-notifications-read');
      AppLogger.success('✓ /mark-all-notifications-read - OK');
    } catch (e) {
      AppLogger.debug('⚠ /mark-all-notifications-read - Expected to fail (requires auth)');
    }

    // Test 34: Delete Notification (DELETE - requires auth)
    try {
      await api.deleteData('/delete-notification/sample-id');
      AppLogger.success('✓ /delete-notification/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /delete-notification/:id - Expected to fail (requires auth)');
    }

    // ============ PAGE SETTINGS ENDPOINTS ============
    AppLogger.info('--- Testing Page Settings Endpoints ---');
    
    // Test 35: Home Banners
    try {
      await api.getData('/get-page-settings/homeBanners');
      AppLogger.success('✓ /get-page-settings/homeBanners - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/homeBanners FAILED', e);
    }

    // Test 36: App Banners
    try {
      await api.getData('/get-page-settings/appBanners');
      AppLogger.success('✓ /get-page-settings/appBanners - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/appBanners FAILED', e);
    }

    // Test 37: Terms and Conditions
    try {
      await api.getData('/get-page-settings/termsAndConditions');
      AppLogger.success('✓ /get-page-settings/termsAndConditions - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/termsAndConditions FAILED', e);
    }

    // Test 38: Privacy Policy
    try {
      await api.getData('/get-page-settings/privacyPolicy');
      AppLogger.success('✓ /get-page-settings/privacyPolicy - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/privacyPolicy FAILED', e);
    }

    // Test 39: Cookie Policy
    try {
      await api.getData('/get-page-settings/cookiePolicy');
      AppLogger.success('✓ /get-page-settings/cookiePolicy - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/cookiePolicy FAILED', e);
    }

    // Test 40: About Us
    try {
      await api.getData('/get-page-settings/aboutUs');
      AppLogger.success('✓ /get-page-settings/aboutUs - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/aboutUs FAILED', e);
    }

    // Test 41: Shipping & Delivery
    try {
      await api.getData('/get-page-settings/shippingDelivery');
      AppLogger.success('✓ /get-page-settings/shippingDelivery - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/shippingDelivery FAILED', e);
    }

    // Test 42: Return & Refund
    try {
      await api.getData('/get-page-settings/returnRefund');
      AppLogger.success('✓ /get-page-settings/returnRefund - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/returnRefund FAILED', e);
    }

    // Test 43: Branding
    try {
      await api.getData('/get-page-settings/branding');
      AppLogger.success('✓ /get-page-settings/branding - OK');
    } catch (e) {
      AppLogger.error('✗ /get-page-settings/branding FAILED', e);
    }

    // ============ ADDRESS ENDPOINTS ============
    AppLogger.info('--- Testing Address Endpoints ---');
    
    // Test 44: Get My Addresses
    try {
      await api.getData('/get-my-addresses');
      AppLogger.success('✓ /get-my-addresses - OK');
    } catch (e) {
      AppLogger.error('✗ /get-my-addresses FAILED', e);
    }

    // Test 45: Add Address (POST - requires auth)
    try {
      await api.postData(
        '/add-address',
        body: {
          'label': 'Home',
          'address': '123 Main St',
          'city': 'City',
          'state': 'State',
          'zipCode': '12345',
          'country': 'Country',
        },
      );
      AppLogger.success('✓ /add-address - OK');
    } catch (e) {
      AppLogger.debug('⚠ /add-address - Expected to fail (requires auth)');
    }

    // Test 46: Update Address (PUT - requires auth)
    try {
      await api.putData(
        '/update-address/sample-id',
        body: {
          'label': 'Home',
          'address': '123 Main St',
          'city': 'City',
          'state': 'State',
          'zipCode': '12345',
          'country': 'Country',
        },
      );
      AppLogger.success('✓ /update-address/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /update-address/:id - Expected to fail (requires auth)');
    }

    // Test 47: Set Default Address (PATCH - requires auth)
    try {
      await api.patchData('/set-default-address/sample-id');
      AppLogger.success('✓ /set-default-address/:id - OK');
    } catch (e) {
      AppLogger.debug('⚠ /set-default-address/:id - Expected to fail (requires auth)');
    }

    AppLogger.info('=== API Test Complete ===');
  }
}

