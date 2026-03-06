import 'package:flutter/material.dart';
import '../../../core/values/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Center icon
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Image.asset('assets/images/splash_icon.png'),
                ),
              ),
            ),

            // Bottom text
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Text(
                'Care You Trust. Medicines You Need.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
