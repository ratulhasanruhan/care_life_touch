import 'package:flutter/material.dart';
import '../../../../core/values/app_colors.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF064E36),
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            // Arrow
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                size: 24,
                color: AppColors.textPrimary,
              ),
          ],
        ),
      ),
    );
  }
}

