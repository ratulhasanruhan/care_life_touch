import 'package:get/get.dart';

import '../../core/utils/app_logger.dart';
import '../models/api_exception.dart';
import '../providers/api_provider.dart';
import '../../modules/home/models/product_model.dart';

class ProductRepository {
  ProductRepository({ApiProvider? apiProvider})
    : _api =
          apiProvider ??
          (Get.isRegistered<ApiProvider>()
              ? Get.find<ApiProvider>()
              : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<List<ProductModel>> getAllProducts() async {
    return getProducts();
  }

  Future<List<ProductModel>> searchProducts(
    String query, {
    int? page,
    int? limit,
  }) async {
    final normalizedQuery = query.trim();
    final encodedQuery = Uri.encodeQueryComponent(normalizedQuery);
    final params = <String, dynamic>{
      'q': encodedQuery,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
    try {
      AppLogger.info('Search API request', params);
      final response = await _api.getData('/search', query: params);
      AppLogger.debug('Search API raw response', response);
      return _extractProducts(response);
    } on ApiException catch (error) {
      // Some environments accept only `q` for /search.
      if (error.statusCode == 400) {
        final fallbackParams = {'q': encodedQuery};
        AppLogger.warning(
          'Search API retry with minimal query',
          fallbackParams,
        );
        final fallback = await _api.getData('/search', query: fallbackParams);
        AppLogger.debug('Search API raw fallback response', fallback);
        return _extractProducts(fallback);
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> filterProducts({
    String? category,
    String? subCategory,
    String? brand,
    double? minPrice,
    double? maxPrice,
    int? minDiscount,
    int? page,
    int? limit,
  }) async {
    final params = <String, dynamic>{
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (subCategory != null && subCategory.trim().isNotEmpty)
        'subCategory': subCategory.trim(),
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minDiscount != null) 'minDiscount': minDiscount,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };

    final strictParams = <String, dynamic>{
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (subCategory != null && subCategory.trim().isNotEmpty)
        'subCategory': subCategory.trim(),
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
    };

    try {
      final response = await _api.getData(
        '/products',
        query: params.isEmpty ? null : params,
      );
      return _extractProducts(response);
    } on ApiException catch (error) {
      // Some environments return 500 when optional filters/pagination are present.
      final shouldTryStrict =
          error.statusCode == 400 ||
          (error.statusCode != null && error.statusCode! >= 500);

      if (shouldTryStrict) {
        final fallback = await _api.getData(
          '/products',
          query: strictParams.isEmpty ? null : strictParams,
        );
        return _extractProducts(fallback);
      }

      rethrow;
    }
  }

  Future<List<ProductModel>> getProducts({
    String? category,
    String? subCategory,
    String? brand,
    String? query,
    int? page,
    int? limit,
  }) async {
    if (query != null && query.trim().isNotEmpty) {
      return searchProducts(query, page: page, limit: limit);
    }

    return filterProducts(
      category: category,
      subCategory: subCategory,
      brand: brand,
      page: page,
      limit: limit,
    );
  }

  Future<List<ProductModel>> getDiscountedProducts() async {
    final response = await _api.getData('/discounted-products');
    return _extractProducts(response);
  }

  Future<List<ProductModel>> getTrendingProducts({int limit = 10}) async {
    final response = await _api.getData(
      '/trending-products',
      query: {'limit': limit},
    );
    return _extractProducts(response);
  }

  Future<List<ProductModel>> getNewProducts({int limit = 10}) async {
    final response = await _api.getData(
      '/new-products',
      query: {'limit': limit},
    );
    return _extractProducts(response);
  }

  Future<List<ProductModel>> getOfferProducts({
    int? page,
    int limit = 10,
    int minDiscount = 1,
  }) async {
    final response = await _api.getData(
      '/offer-products',
      query: {
        if (page != null) 'page': page,
        'limit': limit,
        'minDiscount': minDiscount,
      },
    );
    return _extractProducts(response);
  }

  Future<List<ProductModel>> getRelatedProducts(String slug) async {
    final response = await _api.getData('/related-products/$slug/related');
    return _extractProducts(response);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final response = await _api.getData('/get-all-categories');
    return _extractMapItems(response, preferredKeys: const ['categories']);
  }

  Future<List<Map<String, dynamic>>> getAllBrands() async {
    final response = await _api.getData('/get-all-brands');
    return _extractMapItems(response, preferredKeys: const ['brands']);
  }

  Future<Map<String, dynamic>> getFilterOptions() async {
    final response = await _api.getData('/products-filter-options');
    if (response is! Map) {
      throw ApiException('Invalid filter options response.', details: response);
    }
    final map = response.map((key, value) => MapEntry(key.toString(), value));
    final data = map['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return map;
  }

  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _api.getData('/get-product-by-slug/$slug');
    if (response is! Map) {
      throw ApiException(
        'Invalid product details response.',
        details: response,
      );
    }

    final map = response.map((key, value) => MapEntry(key.toString(), value));
    final product = map['product'];
    if (product is Map<String, dynamic>) {
      return ProductModel.fromJson(product);
    }
    if (product is Map) {
      return ProductModel.fromJson(
        product.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    throw ApiException('Product not found in response.', details: map);
  }

  List<ProductModel> _extractProducts(dynamic response) {
    final list = _findProductList(response);
    if (list == null) {
      throw ApiException('Invalid products response.', details: response);
    }

    return list
        .whereType<Map>()
        .map(
          (item) => ProductModel.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  List<dynamic>? _findProductList(dynamic value) {
    if (value is List) {
      return value;
    }

    final map = _toMap(value);
    if (map == null) {
      return null;
    }

    for (final key in const [
      'products',
      'items',
      'result',
      'results',
      'docs',
    ]) {
      final candidate = map[key];
      if (candidate is List) {
        return candidate;
      }
    }

    for (final key in const ['data', 'payload', 'meta']) {
      final candidate = _findProductList(map[key]);
      if (candidate != null) {
        return candidate;
      }
    }

    for (final candidate in map.values) {
      final nested = _findProductList(candidate);
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _extractMapItems(
    dynamic response, {
    List<String> preferredKeys = const [],
  }) {
    final root = _toMap(response);
    if (root == null) {
      return const [];
    }

    final candidates = <dynamic>[
      for (final key in preferredKeys) root[key],
      root['data'],
      root['items'],
      root['result'],
      root,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate.map(_toMap).whereType<Map<String, dynamic>>().toList();
      }

      final nested = _toMap(candidate);
      if (nested != null) {
        final nestedList = nested['items'] ?? nested['data'];
        if (nestedList is List) {
          return nestedList
              .map(_toMap)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }
    }

    return const [];
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
