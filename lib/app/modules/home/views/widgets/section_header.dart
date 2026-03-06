import 'package:flutter/material.dart';

/// Section Header Widget - Reusable section header with title and view all
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final Widget? extra;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF01060F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (extra != null) ...[
                  const SizedBox(width: 8),
                  extra!,
                ],
              ],
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF064E36),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Offer Timer Widget
class OfferTimer extends StatelessWidget {
  final String time;

  const OfferTimer({super.key, this.time = '12:12:30'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF064E36),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 15),
          const SizedBox(width: 3),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
