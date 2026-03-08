/// Product filter types
enum ProductFilterType { all, medicine, device }

/// Price filter options
enum PriceFilterMode { all, under500, between500To1000, between1000To1500, over2000, custom }

/// Discount filter options
enum DiscountFilterMode { all, above10, above20, above30, above50 }

/// Product filter model
class ProductFilterState {
  final ProductFilterType type;
  final PriceFilterMode priceMode;
  final double? minPrice;
  final double? maxPrice;
  final DiscountFilterMode discountMode;
  final String? selectedBrand;

  const ProductFilterState({
    this.type = ProductFilterType.all,
    this.priceMode = PriceFilterMode.all,
    this.minPrice,
    this.maxPrice,
    this.discountMode = DiscountFilterMode.all,
    this.selectedBrand,
  });

  ProductFilterState copyWith({
    ProductFilterType? type,
    PriceFilterMode? priceMode,
    double? minPrice,
    double? maxPrice,
    DiscountFilterMode? discountMode,
    String? selectedBrand,
  }) {
    return ProductFilterState(
      type: type ?? this.type,
      priceMode: priceMode ?? this.priceMode,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      discountMode: discountMode ?? this.discountMode,
      selectedBrand: selectedBrand ?? this.selectedBrand,
    );
  }

  bool get hasActiveFilters =>
      type != ProductFilterType.all ||
      priceMode != PriceFilterMode.all ||
      discountMode != DiscountFilterMode.all ||
      selectedBrand != null;
}

