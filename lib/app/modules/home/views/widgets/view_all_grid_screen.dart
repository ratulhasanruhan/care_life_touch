import 'package:care_life_touch/app/global_widgets/primary_appbar.dart';
import 'package:flutter/material.dart';

/// Reusable view-all screen for small catalog items like categories and brands.
class ViewAllGridScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final int labelMaxLines;
  final double labelFontSize;
  final double cardHeight;
  final ValueChanged<String>? onItemTap;

  const ViewAllGridScreen({
    super.key,
    required this.title,
    required this.items,
    this.labelMaxLines = 1,
    this.labelFontSize = 12,
    this.cardHeight = 106,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;
    const crossSpacing = 10.0;
    const mainSpacing = 12.0;
    const crossAxisCount = 4;
    final itemWidth =
        (MediaQuery.of(context).size.width -
            (horizontalPadding * 2) -
            (crossSpacing * 3)) /
        crossAxisCount;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(title: title),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossSpacing,
          mainAxisSpacing: mainSpacing,
          childAspectRatio: itemWidth / cardHeight,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final name = item['name'] ?? '';
          final imagePath = item['image'] ?? '';

          return GestureDetector(
            onTap: () => onItemTap?.call(name),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 28,
                          color: Color(0xFFE8EAE8),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01060F),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: labelMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
