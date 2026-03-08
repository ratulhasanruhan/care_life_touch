import 'package:get/get.dart';
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
  final searchText = ''.obs;
  final allProducts = <ProductModel>[].obs;
  final filterState = const ProductFilterState().obs;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
  }

  void onSearchChanged(String value) {
    searchText.value = value.trim().toLowerCase();
  }

  void applyFilters(ProductFilterState filter) {
    filterState.value = filter;
  }

  void resetFilters() {
    filterState.value = const ProductFilterState();
  }

  List<ProductModel> get filteredProducts {
    return _applyFilterPipeline(_productsForType(query.type));
  }

  List<ProductModel> get brandOfferProducts {
    final base = _productsForType(ProductListingType.brand)
        .where((product) => product.hasOffer)
        .toList();
    return _applyFilterPipeline(base);
  }

  List<ProductModel> get brandNewProducts {
    final base = _applyFilterPipeline(_productsForType(ProductListingType.brand));
    return base.take(4).toList();
  }

  List<ProductModel> get brandAllProducts {
    return _applyFilterPipeline(_productsForType(ProductListingType.brand));
  }

  List<ProductModel> _applyFilterPipeline(List<ProductModel> source) {
    var items = source;

    // Apply search filter
    final text = searchText.value;
    if (text.isNotEmpty) {
      items = items.where((product) {
        return product.name.toLowerCase().contains(text) ||
            product.brand.toLowerCase().contains(text);
      }).toList();
    }

    final filter = filterState.value;

    // Apply type filter (medicine vs device)
    if (filter.type != ProductFilterType.all) {
      items = items.where((product) {
        final isDevice = _isDeviceProduct(product);
        return filter.type == ProductFilterType.device ? isDevice : !isDevice;
      }).toList();
    }

    // Apply price range filter
    final range = _resolvePriceRange(filter);
    if (range != null) {
      items = items.where((product) => _isInPriceRange(product, range.$1, range.$2)).toList();
    }

    // Apply discount filter
    if (filter.discountMode != DiscountFilterMode.all) {
      items = items.where((product) => _matchesDiscountFilter(product, filter.discountMode)).toList();
    }

    // Apply brand filter
    if (filter.selectedBrand != null) {
      items = items.where((product) {
        return product.brand.toLowerCase().contains(filter.selectedBrand!.toLowerCase());
      }).toList();
    }

    return items;
  }

  (double, double)? _resolvePriceRange(ProductFilterState filter) {
    switch (filter.priceMode) {
      case PriceFilterMode.all:
        return null;
      case PriceFilterMode.under500:
        return (0, 500);
      case PriceFilterMode.between500To1000:
        return (500, 1000);
      case PriceFilterMode.between1000To1500:
        return (1000, 1500);
      case PriceFilterMode.over2000:
        return (2000, double.infinity);
      case PriceFilterMode.custom:
        final min = filter.minPrice;
        final max = filter.maxPrice;
        if (min == null && max == null) {
          return null;
        }
        return (min ?? 0, max ?? double.infinity);
    }
  }

  bool _matchesDiscountFilter(ProductModel product, DiscountFilterMode mode) {
    if (!product.hasOffer) return false;

    // Extract discount percentage from offer label (if any)
    // For now, we'll assume products with offers match all discount filters
    // You can enhance this with actual discount percentage in ProductModel
    return product.hasOffer;
  }

  bool _isInPriceRange(ProductModel product, double min, double max) {
    final priceMin = product.price;
    final priceMax = product.maxPrice ?? product.price;
    return priceMax >= min && priceMin <= max;
  }

  bool _isDeviceProduct(ProductModel product) {
    final text = '${product.name} ${product.brand}'.toLowerCase();
    const deviceKeywords = [
      'device',
      'monitor',
      'machine',
      'kit',
      'mask',
      'thermometer',
      'nebulizer',
      'glucose',
      'bp',
    ];
    return deviceKeywords.any(text.contains);
  }

  List<ProductModel> _productsForType(ProductListingType type) {
    switch (type) {
      case ProductListingType.category:
        final category = (query.keyword ?? '').toLowerCase();
        if (category.contains('capsule')) {
          final items = allProducts
              .where((product) => product.name.toLowerCase().contains('capsule'))
              .toList();
          return items.isEmpty ? allProducts : items;
        }
        if (category.contains('tablet')) {
          final items = allProducts
              .where((product) => product.name.toLowerCase().contains('tablet'))
              .toList();
          return items.isEmpty ? allProducts : items;
        }
        if (category.contains('unani')) {
          final items = allProducts
              .where((product) => product.brand.toLowerCase().contains('incepta'))
              .toList();
          return items.isEmpty ? allProducts : items;
        }
        return allProducts;
      case ProductListingType.brand:
        final brand = (query.keyword ?? '').toLowerCase().replaceAll('\n', ' ').trim();
        if (brand.isEmpty) {
          return allProducts;
        }
        final items = allProducts.where((product) {
          final value = product.brand.toLowerCase();
          return value.contains(brand) ||
              brand.split(' ').any((part) => part.length > 2 && value.contains(part));
        }).toList();
        return items.isEmpty ? allProducts : items;
      case ProductListingType.trending:
        return allProducts.take(8).toList();
      case ProductListingType.newArrival:
        return allProducts.reversed.take(8).toList();
      case ProductListingType.offers:
        final items = allProducts.where((product) => product.hasOffer).toList();
        return items.isEmpty ? allProducts : items;
      case ProductListingType.all:
        return allProducts;
    }
  }

  Future<void> _loadProducts() async {
    isLoading.value = true;
    allProducts.value = await _productRepository.getAllProducts();
    isLoading.value = false;
  }
}
