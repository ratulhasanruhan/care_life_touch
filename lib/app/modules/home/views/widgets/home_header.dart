import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Home Header Widget - Custom header with location and search
class HomeHeader extends StatelessWidget {
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final Function(String)? onSearch;

  const HomeHeader({
    super.key,
    this.onLocationTap,
    this.onNotificationTap,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SvgPicture.asset(
                'svg/ic_location.svg'
              ),

              // Location and Notification Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Location Section
                  GestureDetector(
                    onTap: onLocationTap,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Text(
                                  'Deliver to',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white, size: 16),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Jessore Khulna, Bangladesh',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
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
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          // Notification Badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEAB308),
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search Your Needs...',
                    hintStyle: TextStyle(
                      color: Color(0xFFA2A8AF),
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFFA2A8AF),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: onSearch,
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

