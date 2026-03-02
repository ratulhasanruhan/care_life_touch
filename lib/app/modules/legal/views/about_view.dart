import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/legal_controller.dart';

class AboutView extends GetView<LegalController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'About Care Life Touch',
              content:
                  'Care Life Touch is a revolutionary healthcare platform designed to make quality healthcare accessible to everyone. Our mission is to bridge the gap between patients and quality medicines, ensuring you get the care you trust and the medicines you need.',
            ),
            _buildSection(
              title: 'Our Mission',
              content:
                  'To provide a seamless, reliable, and user-friendly platform for purchasing medicines online with complete transparency, affordability, and professional healthcare guidance.',
            ),
            _buildSection(
              title: 'Our Vision',
              content:
                  'To become the most trusted online medicine platform in the region, delivering convenience and quality healthcare to millions of people.',
            ),
            _buildSection(
              title: 'Why Choose Care Life Touch?',
              content:
                  '• Verified Medicines: All medicines are sourced from licensed pharmacies\n• Professional Guidance: Access to licensed pharmacists for consultation\n• Affordable Prices: Competitive pricing with regular discounts\n• Fast Delivery: Quick and reliable delivery to your doorstep\n• Secure Transactions: Bank-level security for all transactions\n• Privacy Protected: Your health information is completely confidential',
            ),
            _buildSection(
              title: 'Our Values',
              content:
                  '• Trust: We prioritize your confidence in our services\n• Quality: Only the best medicines and services\n• Affordability: Making healthcare accessible to all\n• Innovation: Continuously improving our platform\n• Customer Care: Your satisfaction is our priority',
            ),
            _buildSection(
              title: 'Contact Information',
              content:
                  'Email: support@carelivetouch.com\nPhone: 1-800-CARE-TOUCH\nAddress: Healthcare Square, Medical District\n\nWe\'re available 24/7 to help you with any questions or concerns.',
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

