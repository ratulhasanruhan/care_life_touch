import 'package:flutter/material.dart';

/// Category Item Widget
class CategoryItem extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.name,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        child: Column(
          children: [
            // Category Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.category,
                        size: 32,
                        color: Color(0xFFE8EAE8),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Category Name
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF01060F),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Categories List Widget
class CategoriesList extends StatelessWidget {
  final List<Map<String, String>> categories;
  final Function(String)? onCategoryTap;

  const CategoriesList({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            margin: EdgeInsets.only(
              right: index < categories.length - 1 ? 10 : 0,
            ),
            child: CategoryItem(
              name: category['name']!,
              imagePath: category['image']!,
              onTap: () => onCategoryTap?.call(category['name']!),
            ),
          );
        },
      ),
    );
  }
}
