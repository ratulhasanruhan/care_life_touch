import 'package:flutter/material.dart';
import 'widgets/view_all_grid_screen.dart';

class AllBrandsView extends StatelessWidget {
  final List<Map<String, String>> brands;
  final ValueChanged<String>? onBrandTap;

  const AllBrandsView({
    super.key,
    required this.brands,
    this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    return ViewAllGridScreen(
      title: 'Brands',
      items: brands,
      labelMaxLines: 2,
      labelFontSize: 10,
      cardHeight: 120,
      onItemTap: onBrandTap,
    );
  }
}

