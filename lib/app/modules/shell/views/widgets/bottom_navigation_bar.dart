import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/values/app_colors.dart';

/// Bottom Navigation Bar Widget - SVG Version
///
/// A custom bottom navigation bar with 4 tabs using SVG icons:
/// - Home (active by default, green background)
/// - Products (3D box icon)
/// - My Bag (shopping bag icon)
/// - More (menu dots icon)
///
/// Features:
/// - SVG icons for crisp, scalable graphics
/// - Active tab has green background circle (40px)
/// - Inactive tabs have light background (FAFAFA)
/// - Dynamic color theming
/// - Optimized rendering
/// - Smooth transitions
///
/// Example Usage:
/// ```dart
/// BottomNavigationBarWidget(
///   currentIndex: 0,
///   onTap: (index) {
///     setState(() => currentIndex = index);
///   },
/// )
/// ```

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // SVG icon paths
  static const String _homeIcon = 'assets/svg/home.svg';
  static const String _productsIcon = 'assets/svg/products.svg';
  static const String _bagIcon = 'assets/svg/bag.svg';
  static const String _moreIcon = 'assets/svg/more.svg';

  // Tab configuration
  static const List<_TabConfig> _tabs = [
    _TabConfig(label: 'Home', icon: _homeIcon),
    _TabConfig(label: 'Products', icon: _productsIcon),
    _TabConfig(label: 'My Bag', icon: _bagIcon),
    _TabConfig(label: 'More', icon: _moreIcon),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE8EAE8),
            width: 1.5,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 200,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _tabs.length,
          (index) => _buildTab(
            index: index,
            config: _tabs[index],
            isActive: currentIndex == index,
            onTap: () => onTap(index),
          ),
        ),
      ),
    );
  }

  /// Build individual tab with SVG icon
  Widget _buildTab({
    required int index,
    required _TabConfig config,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFF064E36);
    final inactiveColor = const Color(0xFF01060F);
    final activeBgColor = const Color(0xFF064E36);
    final inactiveBgColor = const Color(0xFFFAFAFA);
    final textColor = isActive ? activeColor : inactiveColor;
    final iconColor = isActive ? AppColors.white : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background circle - Optimized with SVG
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeBgColor : inactiveBgColor,
            ),
            child: Center(
              child: SvgPicture.asset(
                config.icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Label - Optimized
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab configuration class
class _TabConfig {
  final String label;
  final String icon;

  const _TabConfig({
    required this.label,
    required this.icon,
  });
}


