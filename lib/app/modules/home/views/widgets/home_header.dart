import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';

/// Home Header Widget - Custom header with location and search
class HomeHeader extends StatefulWidget {
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final Function(String)? onSearch;
  final int unreadNotificationCount;
  final String locationText;
  final bool isLocationLoading;
  final bool hasLocationError;
  final List<String> searchSuggestions;

  const HomeHeader({
    super.key,
    this.onLocationTap,
    this.onNotificationTap,
    this.onSearch,
    this.unreadNotificationCount = 0,
    required this.locationText,
    required this.isLocationLoading,
    required this.hasLocationError,
    this.searchSuggestions = const [],
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  List<String> _filteredSuggestions = [];
  List<String> _searchHistory = [];
  bool _showSuggestions = false;
  final _storage = GetStorage();
  static const _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

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
      _searchHistory.removeWhere((item) => item.toLowerCase() == trimmedQuery.toLowerCase());
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
    if (query.trim().isEmpty) {
      setState(() {
        // Show search history first, then suggestions
        _filteredSuggestions = [
          ..._searchHistory.take(8),
          ...widget.searchSuggestions
              .where((s) => !_searchHistory.contains(s))
              .take(8 - _searchHistory.take(8).length)
        ];
        _showSuggestions = _searchFocusNode.hasFocus && _filteredSuggestions.isNotEmpty;
      });
    } else {
      final lowerQuery = query.toLowerCase().trim();

      // Filter search history
      final historyMatches = _searchHistory
          .where((item) => item.toLowerCase().contains(lowerQuery))
          .toList();

      // Filter suggestions with better ranking
      List<String> suggestionMatches = widget.searchSuggestions.toList();

      // Remove items already in history
      suggestionMatches.removeWhere((s) =>
          historyMatches.any((h) => h.toLowerCase() == s.toLowerCase())
      );

      // Filter only items that match the query
      suggestionMatches = suggestionMatches
          .where((suggestion) => suggestion.toLowerCase().contains(lowerQuery))
          .toList();

      // Sort by relevance: prefix matches first, then contains matches
      suggestionMatches.sort((a, b) {
        final aLower = a.toLowerCase();
        final bLower = b.toLowerCase();

        final aStartsWith = aLower.startsWith(lowerQuery);
        final bStartsWith = bLower.startsWith(lowerQuery);

        // Prefix matches come first
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        // If both are prefix or both are contains, sort by length (shorter first)
        if (aStartsWith && bStartsWith) return a.length.compareTo(b.length);

        return 0;
      });

      // Combine: history matches first, then suggestions
      _filteredSuggestions = [
        ...historyMatches.take(8),
        ...suggestionMatches.take(8 - historyMatches.take(8).length)
      ];

      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus && _filteredSuggestions.isNotEmpty;
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    _addToSearchHistory(suggestion);
    _searchController.clear();
    _searchFocusNode.unfocus();
    _hideSuggestions();
    widget.onSearch?.call(suggestion);
  }

  void _onSearchSubmitted(String value) {
    _addToSearchHistory(value);
    _searchController.clear();
    _searchFocusNode.unfocus();
    _hideSuggestions();
    widget.onSearch?.call(value);
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
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
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
                        if (widget.unreadNotificationCount > 0)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD400),
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
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
    return Column(
      children: [
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onTapOutside: (_) => _searchFocusNode.unfocus(),
          onChanged: _filterSuggestions,
          onSubmitted: _onSearchSubmitted,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
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
            fillColor: Colors.white.withValues(alpha: 0.1),
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA2A8AF),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFFA2A8AF),
              size: 20,
            ),
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
    );
  }

  Widget _buildSuggestionTile(String suggestion, int index) {
    final isFromHistory = _searchHistory.contains(suggestion);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSuggestionTap(suggestion),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: index < _filteredSuggestions.length - 1
                ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFFEEEEEE),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isFromHistory ? Icons.history : Icons.search,
                size: 18,
                color: const Color(0xFFA2A8AF),
              ),
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
}
