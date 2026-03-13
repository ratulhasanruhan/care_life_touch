import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/more_controller.dart';
import 'widgets/menu_item.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'More',
        showBackButton: false,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile image
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF6EE7BF),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.5),
                child: Obx(
                  () => controller.userImage.value.isEmpty
                      ? Container(
                          color: const Color(0xFFF6F6F6),
                          child: const Icon(
                            Icons.person_outline,
                            size: 60,
                            color: Color(0xFF064E36),
                          ),
                        )
                      : _buildProfileImage(controller.userImage.value),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // User name
        Obx(
          () => Text(
            controller.userName.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Change photo button
        GestureDetector(
          onTap: controller.changePhoto,
          child: const Text(
            'Change Photo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF064E36),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          MenuItem(
            icon: Icons.person_outline,
            title: 'My Profile',
            onTap: controller.navigateToProfile,
          ),
          _buildDivider(),
          MenuItem(
            icon: Icons.location_on_outlined,
            title: 'My Address',
            onTap: controller.navigateToAddress,
          ),
          _buildDivider(),
          MenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            onTap: controller.navigateToOrders,
          ),
          _buildDivider(),
          MenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: controller.navigateToSettings,
          ),
          _buildDivider(),
          MenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: controller.navigateToAbout,
          ),
          _buildDivider(),
          MenuItem(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            onTap: controller.navigateToPrivacyPolicy,
          ),
          _buildDivider(),
          MenuItem(
            icon: Icons.description_outlined,
            title: 'Teams & Conditions',
            onTap: controller.navigateToTerms,
          ),
          _buildDivider(),
          MenuItem(
            icon: Icons.logout_outlined,
            title: 'Sign Out',
            onTap: controller.signOut,
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: AppColors.border,
    );
  }

  Widget _buildProfileImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }

    return Container(
      color: const Color(0xFFF6F6F6),
      child: const Icon(
        Icons.person_outline,
        size: 60,
        color: Color(0xFF064E36),
      ),
    );
  }
}

