import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/legal_controller.dart';

class PrivacyView extends GetView<LegalController> {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Privacy Policy',
              content:
                  'Care Life Touch ("we" or "us" or "our") operates the Care Life Touch mobile application. This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.',
            ),
            _buildSection(
              title: '1. Information Collection and Use',
              content:
                  'We collect several different types of information for various purposes to provide and improve our Service to you.',
            ),
            _buildSection(
              title: 'Personal Data',
              content:
                  'While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). This may include, but is not limited to:\n\n• Email address\n• First name and last name\n• Phone number\n• Address, State, Province, ZIP/Postal code, City\n• Cookies and Usage Data',
            ),
            _buildSection(
              title: 'Usage Data',
              content:
                  'When you access the Service by or through a mobile device, we may collect certain information automatically, including, but not limited to, the type of mobile device you use, your mobile device unique ID, the IP address of your mobile device, your mobile operating system, the type of mobile browser you use, unique device identifiers and other diagnostic data ("Usage Data").',
            ),
            _buildSection(
              title: '2. Security of Data',
              content:
                  'The security of your data is important to us, but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
            ),
            _buildSection(
              title: '3. Changes to This Privacy Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "effective date" at the top of this Privacy Policy.',
            ),
            _buildSection(
              title: '4. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at: privacy@carelivetouch.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
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
