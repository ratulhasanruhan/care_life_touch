import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/product_model.dart';

/// Home Header Widget - Custom header with location and search
class HomeHeader extends StatefulWidget {
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final Function(String)? onSearch;
  final ValueChanged<String>? onSearchChanged;
  final int unreadNotificationCount;
  final String locationText;
  final bool isLocationLoading;
  final bool hasLocationError;
  final List<ProductModel> searchSuggestions;
  final bool isSearchingSuggestions;

  const HomeHeader({
    super.key,
    this.onLocationTap,
    this.onNotificationTap,
    this.onSearch,
    this.onSearchChanged,
    this.unreadNotificationCount = 0,
    required this.locationText,
    required this.isLocationLoading,
    required this.hasLocationError,
    this.searchSuggestions = const [],
    this.isSearchingSuggestions = false,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  List<_SearchSuggestionItem> _filteredSuggestions = [];
  List<String> _searchHistory = [];
  bool _showSuggestions = false;
  final _storage = GetStorage();
  static const _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;
  static const String _productPlaceholderImage = 'assets/demo/product_1.png';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _loadSearchHistory();
  }

  @override
  void didUpdateWidget(HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If search suggestions changed, refresh filtered suggestions
    if (widget.searchSuggestions != oldWidget.searchSuggestions) {
      _filterSuggestions(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      _hideSuggestions();
      return;
    }
    _filterSuggestions(_searchController.text);
  }

  void _hideSuggestions() {
    if (!mounted) return;
    setState(() {
      _showSuggestions = false;
      _filteredSuggestions.clear();
    });
  }

  void _loadSearchHistory() {
    try {
      final history = _storage.read<List>(_searchHistoryKey);
      if (history != null) {
        setState(() {
          _searchHistory = List<String>.from(history);
        });
      }
    } catch (e) {
      // Ignore storage errors
    }
  }

  void _addToSearchHistory(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    try {
      _searchHistory.removeWhere(
        (item) => item.toLowerCase() == trimmedQuery.toLowerCase(),
      );
      _searchHistory.insert(0, trimmedQuery);
      if (_searchHistory.length > _maxHistoryItems) {
        _searchHistory = _searchHistory.sublist(0, _maxHistoryItems);
      }
      _storage.write(_searchHistoryKey, _searchHistory);
    } catch (e) {
      // Ignore storage errors
    }
  }

  void _filterSuggestions(String query) {
    final historyItems = _searchHistory
        .take(8)
        .map(_SearchSuggestionItem.history)
        .toList();

    if (query.trim().isEmpty) {
      setState(() {
        final productItems = _filterProductSuggestions('');
        _filteredSuggestions = [
          ...historyItems,
          ...productItems.take(8 - historyItems.length),
        ];
        _showSuggestions =
            _searchFocusNode.hasFocus && _filteredSuggestions.isNotEmpty;
      });
    } else {
      final lowerQuery = query.toLowerCase().trim();

      final historyMatches = _searchHistory
          .where((item) => item.toLowerCase().contains(lowerQuery))
          .take(8)
          .toList();

      final suggestionMatches = _filterProductSuggestions(lowerQuery);
      final historySuggestionItems = historyMatches
          .map(_SearchSuggestionItem.history)
          .toList();

      _filteredSuggestions = [
        ...historySuggestionItems,
        ...suggestionMatches.take(8 - historySuggestionItems.length),
      ];

      setState(() {
        _showSuggestions =
            _searchFocusNode.hasFocus && _filteredSuggestions.isNotEmpty;
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    _submitSearch(suggestion);
  }

  void _onSearchSubmitted(String value) {
    _submitSearch(value);
  }

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    _addToSearchHistory(query);
    _searchController.clear();
    _searchFocusNode.unfocus();
    _hideSuggestions();
    widget.onSearchChanged?.call('');
    widget.onSearch?.call(query);
  }

  List<_SearchSuggestionItem> _filterProductSuggestions(String query) {
    final lowerQuery = query.trim().toLowerCase();
    final seen = <String>{};

    final products = widget.searchSuggestions.where((product) {
      final name = product.name.trim();
      if (name.isEmpty) return false;
      if (_searchHistory.any(
        (history) => history.toLowerCase() == name.toLowerCase(),
      )) {
        return false;
      }
      return lowerQuery.isEmpty || name.toLowerCase().contains(lowerQuery);
    }).toList();

    products.sort((a, b) {
      if (lowerQuery.isEmpty) {
        return a.name.length.compareTo(b.name.length);
      }

      final aLower = a.name.toLowerCase();
      final bLower = b.name.toLowerCase();
      final aStartsWith = aLower.startsWith(lowerQuery);
      final bStartsWith = bLower.startsWith(lowerQuery);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      if (aStartsWith && bStartsWith)
        return a.name.length.compareTo(b.name.length);
      return a.name.length.compareTo(b.name.length);
    });

    final items = <_SearchSuggestionItem>[];
    for (final product in products) {
      final key = product.id.trim().isNotEmpty
          ? product.id.trim().toLowerCase()
          : product.name.trim().toLowerCase();
      if (key.isEmpty || !seen.add(key)) continue;
      items.add(_SearchSuggestionItem.product(product));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final subtitleText = widget.isLocationLoading
        ? 'Getting location...'
        : widget.hasLocationError
        ? 'Location unavailable. Tap to choose'
        : widget.locationText;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF065F42),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(
            children: [
              // Location and Notification Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Location Section
                  GestureDetector(
                    onTap: widget.onLocationTap,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/ic_location.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: 26,
                          height: 26,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Deliver to',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: widget.onLocationTap,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 220,
                              child: Text(
                                subtitleText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: widget.isLocationLoading
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notification Button
                  GestureDetector(
                    onTap: widget.onNotificationTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: widget.unreadNotificationCount > 0
                          ? SvgPicture.asset('assets/svg/ic_notification.svg')
                          : const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search field with suggestions
              _buildSearchField(),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFieldTapRegion(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onTapOutside: (_) => _searchFocusNode.unfocus(),
            onChanged: (value) {
              _filterSuggestions(value);
              widget.onSearchChanged?.call(value);
            },
            onSubmitted: _onSearchSubmitted,
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF01060F),
            ),
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: 'Search Your Needs...',
              fillColor: Colors.white.withValues(alpha: 0.92),
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFA2A8AF),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF6E767E),
                size: 20,
              ),
              suffixIcon: widget.isSearchingSuggestions
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          // Suggestions dropdown
          if (_showSuggestions && _filteredSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return _buildSuggestionTile(suggestion, index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(_SearchSuggestionItem suggestion, int index) {
    return suggestion.isHistory
        ? _buildHistorySuggestionTile(suggestion.label, index)
        : _buildProductSuggestionTile(suggestion.product!, index);
  }

  Widget _buildHistorySuggestionTile(String suggestion, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSuggestionTap(suggestion),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: index < _filteredSuggestions.length - 1
                ? const Border(
                    bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
                  )
                : null,
          ),
          child: Row(
            children: [
              const Icon(Icons.history, size: 18, color: Color(0xFFA2A8AF)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  suggestion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF01060F),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_outward,
                size: 16,
                color: Color(0xFFA2A8AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSuggestionTile(ProductModel product, int index) {
    final imageWidget = _buildSuggestionImage(product);
    final price = product.price > 0 ? product.price : null;
    final comparePrice = product.maxPrice != null && product.maxPrice! > 0
        ? product.maxPrice
        : null;
    final showComparePrice =
        price != null && comparePrice != null && comparePrice > price;
    final discountLabel = _resolveDiscountLabel(product);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSuggestionTap(product.name),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: index < _filteredSuggestions.length - 1
                ? const Border(
                    bottom: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
                  )
                : null,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFFF4F5F4),
                  child: imageWidget,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF01060F),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          price != null
                              ? '৳${_formatPrice(price)}'
                              : 'Price unavailable',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF064E36),
                          ),
                        ),
                        if (showComparePrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            '৳${_formatPrice(comparePrice)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8C9196),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (discountLabel != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              discountLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_outward,
                size: 16,
                color: Color(0xFFA2A8AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  Widget _buildSuggestionImage(ProductModel product) {
    final imagePath = product.imagePath.trim().isEmpty
        ? _productPlaceholderImage
        : product.imagePath.trim();

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          _productPlaceholderImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_not_supported,
            size: 20,
            color: Color(0xFFC5C9CC),
          ),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        _productPlaceholderImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported,
          size: 20,
          color: Color(0xFFC5C9CC),
        ),
      ),
    );
  }

  String? _resolveDiscountLabel(ProductModel product) {
    final offerLabel = product.offerLabel?.trim();
    if (offerLabel != null && offerLabel.isNotEmpty) {
      return offerLabel;
    }

    final comparePrice = product.maxPrice;
    if (comparePrice != null &&
        comparePrice > 0 &&
        product.price > 0 &&
        comparePrice > product.price) {
      final percentage = (((comparePrice - product.price) / comparePrice) * 100)
          .round();
      if (percentage > 0) {
        return '$percentage% OFF';
      }
    }

    return null;
  }
}

class _SearchSuggestionItem {
  const _SearchSuggestionItem._({
    required this.label,
    required this.isHistory,
    this.product,
  });

  factory _SearchSuggestionItem.history(String label) =>
      _SearchSuggestionItem._(label: label, isHistory: true);

  factory _SearchSuggestionItem.product(ProductModel product) =>
      _SearchSuggestionItem._(
        label: product.name,
        isHistory: false,
        product: product,
      );

  final String label;
  final bool isHistory;
  final ProductModel? product;
}
