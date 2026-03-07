import 'package:flutter/material.dart';
import 'widgets/view_all_grid_screen.dart';

class AllCategoriesView extends StatelessWidget {
  final List<Map<String, String>> categories;
  final ValueChanged<String>? onCategoryTap;

  const AllCategoriesView({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ViewAllGridScreen(
      title: 'Categories',
      items: categories,
      labelMaxLines: 1,
      labelFontSize: 12,
      cardHeight: 106,
      onItemTap: onCategoryTap,
    );
  }
}
