import 'package:flutter/material.dart';

class AppTagChip extends StatelessWidget {
  const AppTagChip({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x1A43505C),
    this.textColor = const Color(0xFF43505C),
    this.borderRadius = 999,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.fontSize = 11,
    this.fontWeight = FontWeight.w600,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }
}

