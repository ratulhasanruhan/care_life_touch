enum ProductListingType { all, category, brand, trending, newArrival, offers }

class ProductsQuery {
  final ProductListingType type;
  final String title;
  final String? keyword;
  final bool showBackButton;

  const ProductsQuery({
    required this.type,
    required this.title,
    this.keyword,
    this.showBackButton = true,
  });

  const ProductsQuery.main()
    : type = ProductListingType.all,
      title = 'Products',
      keyword = null,
      showBackButton = false;
}
