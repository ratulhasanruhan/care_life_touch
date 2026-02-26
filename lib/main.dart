import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/constants/app_constants.dart';
import 'app/core/utils/app_logger.dart';
import 'app/routes/app_pages.dart';

void main() {
  AppLogger.info('🚀 App starting...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      // Navigation observer for logging
      routingCallback: (routing) {
        if (routing?.current != null) {
          AppLogger.navigation(routing!.current);
        }
      },
    );
  }
}
