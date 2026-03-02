import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../controllers/legal_controller.dart';

class TermsView extends GetView<LegalController> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              title: '1. Terms of Use',
              content:
                  'By accessing and using Care Life Touch, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            _buildSection(
              title: '2. License',
              content:
                  'Care Life Touch grants you a limited, non-exclusive, non-transferable license to use our application for personal, non-commercial purposes.',
            ),
            _buildSection(
              title: '3. Disclaimer',
              content:
                  'The materials on Care Life Touch are provided on an "as is" basis. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            ),
            _buildSection(
              title: '4. Limitations',
              content:
                  'In no event shall Care Life Touch or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Care Life Touch.',
            ),
            _buildSection(
              title: '5. Accuracy of Materials',
              content:
                  'The materials appearing on Care Life Touch could include technical, typographical, or photographic errors. We do not warrant that any of the materials on our website are accurate, complete, or current.',
            ),
            _buildSection(
              title: '6. Modifications',
              content:
                  'We may revise these terms of service at any time without notice. By using this website, you are agreeing to be bound by the then current version of these terms of service.',
            ),
            _buildSection(
              title: '7. Governing Law',
              content:
                  'These terms of service are governed by and construed in accordance with the laws of the jurisdiction in which Care Life Touch operates, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
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

