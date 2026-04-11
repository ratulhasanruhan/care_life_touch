import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/api_exception.dart';
import '../../../data/repositories/product_repository.dart';
import '../../home/models/product_model.dart';
import '../models/products_query.dart';
import '../models/product_filter_model.dart';

class ProductsController extends GetxController {
  final ProductsQuery query;
  final ProductRepository _productRepository;

  ProductsController(this.query, {ProductRepository? productRepository})
    : _productRepository = productRepository ?? Get.find<ProductRepository>();

  final isLoading = false.obs;
  final isMutating = false.obs;
  final searchText = ''.obs;
  final allProducts = <ProductModel>[].obs;
  final availableBrands = <Map<String, String>>[].obs;
  final filterState = const ProductFilterState().obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final pageSize = 20.obs;
  final hasMorePages = true.obs;
  final totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize search text from query keyword if it's a search query
    if (query.type == ProductListingType.all && query.keyword != null && query.keyword!.isNotEmpty) {
      searchText.value = query.keyword!.trim().toLowerCase();
    }
    _loadInitialProducts();
    _loadFilterOptions();
    // Auto-search on text change
    ever(searchText, (_) => _handleSearchChange());
  }

  Future<void> _loadInitialProducts() async {
    isLoading.value = true;
    try {
      errorMessage.value = '';
      currentPage.value = 1;

      final products = await _fetchProducts(page: 1);
      allProducts.value = products;
      hasMorePages.value = products.length >= pageSize.value;
    } catch (e) {
      AppLogger.error('Failed to load products', e);
      errorMessage.value = _resolveError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleSearchChange() async {
    if (query.type == ProductListingType.offers) {
      // Offer listing is constrained from the offers API; apply local search only.
      return;
    }

    if (searchText.value.isEmpty) {
      await _loadInitialProducts();
      return;
    }
    await searchProducts(searchText.value);
  }

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      await _loadInitialProducts();
      return;
    }

    isLoading.value = true;
    currentPage.value = 1;
    try {
      errorMessage.value = '';
      final products = await _productRepository.searchProducts(
        query,
        page: 1,
        limit: pageSize.value,
      );
      allProducts.value = products;
      hasMorePages.value = products.length >= pageSize.value;
    } catch (e) {
      AppLogger.error('Search failed', e);
      errorMessage.value = _resolveError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilters(ProductFilterState filter) async {
    filterState.value = filter;
    isLoading.value = true;
    currentPage.value = 1;

    try {
      errorMessage.value = '';
      final (minPrice, maxPrice) = _resolvePriceRange(filter);
      final minDiscount = _effectiveMinDiscount(filter.discountMode);

      final products = await _productRepository.filterProducts(
        category: _categoryFromFilter(filter),
        brand: filter.selectedBrand ?? _queryBrand(),
        minPrice: minPrice,
        maxPrice: maxPrice,
        minDiscount: minDiscount,
        page: 1,
        limit: pageSize.value,
      );
      allProducts.value = products;
      hasMorePages.value = products.length >= pageSize.value;
    } catch (e) {
      AppLogger.error('Filter failed', e);
      errorMessage.value = _resolveError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    filterState.value = const ProductFilterState();
    _loadInitialProducts();
  }

  Future<void> loadMoreProducts() async {
    if (!hasMorePages.value || isMutating.value) return;

    isMutating.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final products = await _fetchProducts(page: nextPage);

      if (products.isNotEmpty) {
        final existingIds = allProducts.map((item) => item.id).toSet();
        final unique = products
            .where((item) => !existingIds.contains(item.id))
            .toList();

        if (unique.isEmpty) {
          hasMorePages.value = false;
          return;
        }

        allProducts.addAll(unique);
        currentPage.value = nextPage;
        hasMorePages.value = unique.length >= pageSize.value;
      } else {
        hasMorePages.value = false;
      }
    } catch (e) {
      AppLogger.error('Load more failed', e);
    } finally {
      isMutating.value = false;
    }
  }

  Future<List<ProductModel>> _fetchProducts({int? page}) async {
    if (query.type == ProductListingType.offers) {
      return _productRepository.getOfferProducts(
        page: page,
        limit: pageSize.value,
        minDiscount: 1,
      );
    }

    final activeSearch = searchText.value.trim();
    if (activeSearch.isNotEmpty) {
      return _productRepository.searchProducts(
        activeSearch,
        page: page,
        limit: pageSize.value,
      );
    }

    final brandQuery = filterState.value.selectedBrand ?? _queryBrand();

    try {
      return await _productRepository.filterProducts(
        category: _queryCategory(),
        brand: brandQuery,
        minDiscount: _effectiveMinDiscount(filterState.value.discountMode),
        page: page,
        limit: pageSize.value,
      );
    } on ApiException catch (error) {
      final titleBrand = query.title.trim();
      final canRetryWithTitle =
          query.type == ProductListingType.brand &&
          filterState.value.selectedBrand == null &&
          titleBrand.isNotEmpty &&
          (brandQuery ?? '').trim() != titleBrand;

      if (!canRetryWithTitle) {
        rethrow;
      }

      AppLogger.warning(
        'Brand query fallback: retrying /products with title brand after ${error.statusCode}',
      );

      return _productRepository.filterProducts(
        category: _queryCategory(),
        brand: titleBrand,
        minDiscount: _effectiveMinDiscount(filterState.value.discountMode),
        page: page,
        limit: pageSize.value,
      );
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      final brands = await _productRepository.getAllBrands();
      final resolved = <Map<String, String>>[];
      final seenQueries = <String>{};

      for (final item in brands) {
        final label =
            (item['name'] ??
                    item['title'] ??
                    item['brand'] ??
                    item['label'] ??
                    '')
                .toString()
                .trim();
        final query = (item['_id'] ?? item['id'] ?? item['query'] ?? label)
            .toString()
            .trim();

        if (label.isEmpty || query.isEmpty || seenQueries.contains(query)) {
          continue;
        }

        resolved.add({'label': label, 'query': query});
        seenQueries.add(query);
      }

      resolved.sort(
        (a, b) => (a['label'] ?? '').toLowerCase().compareTo(
          (b['label'] ?? '').toLowerCase(),
        ),
      );
      availableBrands.assignAll(resolved);
    } catch (_) {
      // Keep modal defaults when brands API is unavailable.
    }
  }

  List<ProductModel> get filteredProducts {
    return _applyFilterPipeline(_productsForType(query.type));
  }

  List<ProductModel> get brandOfferProducts {
    final base = _productsForType(
      ProductListingType.brand,
    ).where((product) => product.hasOffer).toList();
    return _applyFilterPipeline(base);
  }

  List<ProductModel> get brandNewProducts {
    final base = _applyFilterPipeline(
      _productsForType(ProductListingType.brand),
    );
    return base.take(4).toList();
  }

  List<ProductModel> get brandAllProducts {
    return _applyFilterPipeline(_productsForType(ProductListingType.brand));
  }

  void onSearchChanged(String value) {
    searchText.value = value.trim().toLowerCase();
  }

  String _resolveError(dynamic error) {
    if (error is Exception) {
      return error.toString();
    }
    return 'An error occurred. Please try again.';
  }

  (double?, double?) _resolvePriceRange(ProductFilterState filter) {
    switch (filter.priceMode) {
      case PriceFilterMode.all:
        return (null, null);
      case PriceFilterMode.under500:
        return (0, 500);
      case PriceFilterMode.between500To1000:
        return (500, 1000);
      case PriceFilterMode.between1000To1500:
        return (1000, 1500);
      case PriceFilterMode.over2000:
        return (2000, null);
      case PriceFilterMode.custom:
        return (filter.minPrice, filter.maxPrice);
    }
  }

  List<ProductModel> _applyFilterPipeline(List<ProductModel> base) {
    var result = base;

    // Apply search filter
    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.brand.toLowerCase().contains(query) ||
                (p.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    // Brand/category/discount filters are applied by API.

    return result;
  }

  String? _categoryFromFilter(ProductFilterState filter) {
    final fromQuery = _queryCategory();
    if (fromQuery != null && fromQuery.isNotEmpty) {
      return fromQuery;
    }

    switch (filter.type) {
      case ProductFilterType.all:
        return null;
      case ProductFilterType.medicine:
        return 'medicine';
      case ProductFilterType.device:
        return 'device';
    }
  }

  String? _queryCategory() {
    if (query.type != ProductListingType.category) {
      return null;
    }
    final keyword = query.keyword?.trim();
    if (keyword != null && keyword.isNotEmpty) {
      return keyword;
    }
    return null;
  }

  String? _queryBrand() {
    if (query.type != ProductListingType.brand) {
      return null;
    }
    final keyword = query.keyword?.trim();
    if (keyword != null && keyword.isNotEmpty) {
      return keyword;
    }
    return null;
  }

  List<ProductModel> _productsForType(ProductListingType type) {
    switch (type) {
      case ProductListingType.category:
        return allProducts;
      case ProductListingType.brand:
        return allProducts;
      case ProductListingType.trending:
        return allProducts.take(8).toList();
      case ProductListingType.newArrival:
        return allProducts.reversed.take(8).toList();
      case ProductListingType.offers:
        return allProducts.where((p) => p.hasOffer).toList();
      case ProductListingType.all:
        return allProducts;
    }
  }

  int? _resolveMinDiscount(DiscountFilterMode mode) {
    switch (mode) {
      case DiscountFilterMode.all:
        return null;
      case DiscountFilterMode.above10:
        return 10;
      case DiscountFilterMode.above20:
        return 20;
      case DiscountFilterMode.above30:
        return 30;
      case DiscountFilterMode.above50:
        return 50;
    }
  }

  int? _effectiveMinDiscount(DiscountFilterMode mode) {
    final selected = _resolveMinDiscount(mode);
    if (query.type != ProductListingType.offers) {
      return selected;
    }

    // Offers page must always stay constrained to discounted products.
    if (selected == null || selected < 1) {
      return 1;
    }
    return selected;
  }
}
