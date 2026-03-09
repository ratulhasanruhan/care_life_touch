import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../global_widgets/primary_appbar.dart';

class MedicineOverviewView extends StatelessWidget {
  const MedicineOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    // Product name can be retrieved from Get.arguments if needed for dynamic content
    // final productName = Get.arguments as String? ?? 'Paracetamol';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      appBar: PrimaryAppBar(
        title: 'Medicine Overview',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            'Introduction',
            'Paracetamol is a widely used analgesic (pain reliever) and antipyretic (fever reducer). It is commonly used to relieve mild to moderate pain and reduce fever associated with various conditions.',
            showMore: true,
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Uses',
            'Paracetamol is commonly used for:\n\n'
            '• Headache\n'
            '• Toothache\n'
            '• Muscle and joint pain\n'
            '• Back pain\n'
            '• Menstrual pain\n'
            '• Cold and flu symptoms\n'
            '• Fever',
          ),
          const SizedBox(height: 16),
          _buildSection(
            'How It Works',
            'Paracetamol works by reducing the production of chemical substances in the brain that cause pain and increase body temperature.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Dosage (General Guidance)',
            'Adults: As directed by a healthcare professional or according to the product label.\n\n'
            'Children: Dosage depends on age and weight. Always follow pediatric guidance.\n\n'
            '⚠️ Do not exceed the recommended daily dose.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Side Effects',
            'Paracetamol is generally well tolerated when used as directed. Rare side effects may include:\n\n'
            '• Nausea\n'
            '• Allergic reactions (rash, itching)\n'
            '• Liver problems (usually linked to overdose)\n\n'
            'Seek medical attention if unusual symptoms occur.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Precautions',
            '• Avoid exceeding the maximum daily dose.\n'
            '• Consult a healthcare professional if you have liver disease.\n'
            '• Avoid combining with other products containing Paracetamol.\n'
            '• Seek medical advice during pregnancy or breastfeeding.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Storage',
            'Store in a cool, dry place away from direct sunlight and out of reach of children.',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool showMore = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF01060F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.43,
            color: Color(0xB301060F),
          ),
        ),
        if (showMore)
          TextButton(
            onPressed: () {
              // Toggle expand/collapse
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See More',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF064E36),
              ),
            ),
          ),
      ],
    );
  }
}


