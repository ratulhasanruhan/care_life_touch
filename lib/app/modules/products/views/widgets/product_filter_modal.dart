import 'package:care_life_touch/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../global_widgets/custom_button.dart';
import '../../../../global_widgets/custom_text_field.dart';
import '../../controllers/products_controller.dart';
import '../../models/product_filter_model.dart';
import 'filter_widgets.dart';

/// Product filter modal with tabs for different filter types
class ProductFilterModal extends StatefulWidget {
  final ProductsController controller;

  const ProductFilterModal({super.key, required this.controller});

  @override
  State<ProductFilterModal> createState() => _ProductFilterModalState();
}

class _ProductFilterModalState extends State<ProductFilterModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProductFilterState _tempFilter;
  Worker? _brandsWorker;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _brandSearchController = TextEditingController();
  final List<Map<String, String>> _fallbackBrands = const [
    {'label': 'ACME Pharmaceuticals', 'query': 'ACME Pharmaceuticals'},
    {'label': 'Opsonin Pharma', 'query': 'Opsonin Pharma'},
    {'label': 'Aristopharma', 'query': 'Aristopharma'},
    {'label': 'Incepta Pharmaceuticals', 'query': 'Incepta Pharmaceuticals'},
    {'label': 'Square Pharmaceuticals', 'query': 'Square Pharmaceuticals'},
    {'label': 'Beximco Pharmaceuticals', 'query': 'Beximco Pharmaceuticals'},
  ];
  final List<Map<String, String>> _availableBrands = [];
  List<Map<String, String>> _filteredBrands = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tempFilter = widget.controller.filterState.value;
    _syncBrands();
    _brandsWorker = ever<List<Map<String, String>>>(
      widget.controller.availableBrands,
      (_){
      if (!mounted) return;
      setState(_syncBrands);
    });

    if (_tempFilter.minPrice != null) {
      _minPriceController.text = _tempFilter.minPrice!.toInt().toString();
    }
    if (_tempFilter.maxPrice != null) {
      _maxPriceController.text = _tempFilter.maxPrice!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _brandsWorker?.dispose();
    _tabController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _brandSearchController.dispose();
    super.dispose();
  }

  void _syncBrands() {
    final dynamicBrands = widget.controller.availableBrands.toList();
    _availableBrands
      ..clear()
      ..addAll(dynamicBrands.isEmpty ? _fallbackBrands : dynamicBrands);
    _filteredBrands = List.from(_availableBrands);
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = List.from(_availableBrands);
      } else {
        _filteredBrands = _availableBrands
            .where((brand) =>
                (brand['label'] ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Filter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF01060F),
              ),
            ),
          ),

          // Custom Tab Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _FilterTabButton(
                    text: 'Price',
                    isSelected: _tabController.index == 0,
                    onTap: () {
                      setState(() {
                        _tabController.animateTo(0);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterTabButton(
                    text: 'Discount',
                    isSelected: _tabController.index == 1,
                    onTap: () {
                      setState(() {
                        _tabController.animateTo(1);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterTabButton(
                    text: 'Brands',
                    isSelected: _tabController.index == 2,
                    onTap: () {
                      setState(() {
                        _tabController.animateTo(2);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPriceTab(),
                _buildDiscountTab(),
                _buildBrandsTab(),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Reset',
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.medium,
                    fullWidth: true,
                    textColor: AppColors.textPrimary,
                    onPressed: () {
                      widget.controller.resetFilters();
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Apply',
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                    fullWidth: true,
                    onPressed: () {
                      widget.controller.applyFilters(_tempFilter);
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPriceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilterRadioOption(
          title: 'All Prices',
          isSelected: _tempFilter.priceMode == PriceFilterMode.all,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(priceMode: PriceFilterMode.all);
            });
          },
        ),
        FilterRadioOption(
          title: 'Under ৳500',
          isSelected: _tempFilter.priceMode == PriceFilterMode.under500,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(priceMode: PriceFilterMode.under500);
            });
          },
        ),
        FilterRadioOption(
          title: '৳500 - ৳1000',
          isSelected: _tempFilter.priceMode == PriceFilterMode.between500To1000,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(priceMode: PriceFilterMode.between500To1000);
            });
          },
        ),
        FilterRadioOption(
          title: '৳1000 - ৳1500',
          isSelected: _tempFilter.priceMode == PriceFilterMode.between1000To1500,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(priceMode: PriceFilterMode.between1000To1500);
            });
          },
        ),
        FilterRadioOption(
          title: 'Over ৳2000',
          isSelected: _tempFilter.priceMode == PriceFilterMode.over2000,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(priceMode: PriceFilterMode.over2000);
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _minPriceController,
                hintText: 'Min ৳',
                keyboardType: TextInputType.number,
                onTap: () {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(priceMode: PriceFilterMode.custom);
                  });
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _tempFilter = _tempFilter.copyWith(
                        priceMode: PriceFilterMode.custom,
                        minPrice: double.tryParse(value),
                      );
                    });
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('To', style: TextStyle(color: Color(0xFF01060F))),
            ),
            Expanded(
              child: CustomTextField(
                controller: _maxPriceController,
                hintText: 'Max ৳',
                keyboardType: TextInputType.number,
                onTap: () {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(priceMode: PriceFilterMode.custom);
                  });
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _tempFilter = _tempFilter.copyWith(
                        priceMode: PriceFilterMode.custom,
                        maxPrice: double.tryParse(value),
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscountTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilterRadioOption(
          title: 'All Discounts',
          isSelected: _tempFilter.discountMode == DiscountFilterMode.all,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(discountMode: DiscountFilterMode.all);
            });
          },
        ),
        FilterRadioOption(
          title: '10% and above',
          isSelected: _tempFilter.discountMode == DiscountFilterMode.above10,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(discountMode: DiscountFilterMode.above10);
            });
          },
        ),
        FilterRadioOption(
          title: '20% and above',
          isSelected: _tempFilter.discountMode == DiscountFilterMode.above20,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(discountMode: DiscountFilterMode.above20);
            });
          },
        ),
        FilterRadioOption(
          title: '30% and above',
          isSelected: _tempFilter.discountMode == DiscountFilterMode.above30,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(discountMode: DiscountFilterMode.above30);
            });
          },
        ),
        FilterRadioOption(
          title: '50% and above',
          isSelected: _tempFilter.discountMode == DiscountFilterMode.above50,
          onTap: () {
            setState(() {
              _tempFilter = _tempFilter.copyWith(discountMode: DiscountFilterMode.above50);
            });
          },
        ),
      ],
    );
  }

  Widget _buildBrandsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomTextField(
            controller: _brandSearchController,
            hintText: 'Search brands...',
            prefixIcon: const Icon(Icons.search, size: 20),
            onChanged: _filterBrands,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredBrands.length,
            itemBuilder: (context, index) {
              final brand = _filteredBrands[index];
              final label = brand['label'] ?? '';
              final query = brand['query'] ?? label;
              return FilterRadioOption(
                title: label,
                isSelected: _tempFilter.selectedBrand == query,
                onTap: () {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(
                      selectedBrand:
                          _tempFilter.selectedBrand == query ? null : query,
                    );
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Custom tab button matching Figma design
class _FilterTabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF064E36) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF01060F),
          ),
        ),
      ),
    );
  }
}

