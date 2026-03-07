import 'package:flutter/material.dart';

class ProductsHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const ProductsHeader({
    super.key,
    required this.title,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCFC),
        boxShadow: [
          BoxShadow(
            color: Color(0x40A7A9B7),
            blurRadius: 80,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showBackButton)
                Positioned(
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF43505C),
                      ),
                    ),
                  ),
                ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 26 / 18,
                  letterSpacing: -0.02,
                  color: Color(0xFF01060F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

