import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import 'widgets/bottom_navigation_bar.dart';
import '../../home/views/home_view.dart';
import '../../cart/views/cart_view.dart';

/// Shell View - Main container with bottom navigation
///
/// This view wraps the main navigation structure with a bottom nav bar
/// allowing users to switch between Home, Products, Cart, and Profile sections.
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: _buildBody(controller.currentTabIndex.value),
        bottomNavigationBar: BottomNavigationBarWidget(
          currentIndex: controller.currentTabIndex.value,
          onTap: controller.onTabChanged,
        ),
      ),
    );
  }

  /// Build the body based on current tab index
  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return _buildProductsPlaceholder();
      case 2:
        return const CartView();
      case 3:
        return _buildProfilePlaceholder();
      default:
        return const HomeView();
    }
  }

  /// Placeholder for Products section
  Widget _buildProductsPlaceholder() {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(child: Text('Products Section')),
    );
  }

  /// Placeholder for Profile section
  Widget _buildProfilePlaceholder() {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: const Center(child: Text('Profile Section')),
    );
  }
}
