import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Home Header Widget - Custom header with location and search
class HomeHeader extends StatelessWidget {
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final Function(String)? onSearch;
  final String locationText;
  final bool isLocationLoading;
  final bool hasLocationError;

  const HomeHeader({
    super.key,
    this.onLocationTap,
    this.onNotificationTap,
    this.onSearch,
    required this.locationText,
    required this.isLocationLoading,
    required this.hasLocationError,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText = isLocationLoading
        ? 'Getting location...'
        : hasLocationError
            ? 'Location unavailable. Tap to choose'
            : locationText;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF065F42),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(
            children: [
              // Location and Notification Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Location Section
                  GestureDetector(
                    onTap: onLocationTap,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/ic_location.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: 26,
                          height: 26,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Deliver to',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: onLocationTap,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 220,
                              child: Text(
                                subtitleText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isLocationLoading
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notification Button
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset('assets/svg/ic_notification.svg'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                onSubmitted: onSearch,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Search Your Needs...',
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFA2A8AF),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFFA2A8AF),
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
