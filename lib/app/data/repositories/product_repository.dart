import 'package:get/get.dart';

import '../models/api_exception.dart';
import '../providers/api_provider.dart';
import '../../modules/home/models/product_model.dart';

class ProductRepository {
  ProductRepository({ApiProvider? apiProvider})
    : _api = apiProvider ??
          (Get.isRegistered<ApiProvider>()
              ? Get.find<ApiProvider>()
              : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<List<ProductModel>> getAllProducts() async {
    return getProducts();
  }

  Future<List<ProductModel>> getProducts({
    String? category,
    String? subCategory,
    String? brand,
    String? query,
  }) async {
    final params = <String, dynamic>{
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (subCategory != null && subCategory.trim().isNotEmpty)
        'subCategory': subCategory.trim(),
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };

    final endpoint = params.containsKey('q') ? '/search' : '/products';
    final response = await _api.getData(endpoint, query: params.isEmpty ? null : params);
    return _extractProducts(response);
  }

  Future<List<ProductModel>> getDiscountedProducts() async {
    final response = await _api.getData('/discounted-products');
    return _extractProducts(response);
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
      throw ApiException('Invalid product details response.', details: response);
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
    if (response is Map) {
      final map = response.map((key, value) => MapEntry(key.toString(), value));
      final products = map['products'] ?? map['data'] ?? map['items'];
      if (products is List) {
        return products
            .whereType<Map>()
            .map((item) => ProductModel.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ))
            .toList();
      }
    }

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .toList();
    }

    throw ApiException('Invalid products response.', details: response);
  }
}
