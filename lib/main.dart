import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/constants/app_constants.dart';
import 'app/core/utils/app_logger.dart';
import 'app/data/providers/api_provider.dart';
import 'app/data/providers/storage_provider.dart';
import 'app/data/repositories/auth_repository.dart';
import 'app/data/repositories/address_repository.dart';
import 'app/data/repositories/cart_repository.dart';
import 'app/data/repositories/order_repository.dart';
import 'app/data/repositories/product_repository.dart';
import 'app/modules/cart/controllers/cart_controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('🚀 App starting...');

  // Initialize storage
  final storage = StorageService();
  await storage.init();
  Get.put(storage);
  Get.put(ApiProvider(), permanent: true);
  Get.put(AuthRepository(), permanent: true);
  Get.put(AddressRepository(), permanent: true);
  Get.put(CartRepository(), permanent: true);
  Get.put(OrderRepository(), permanent: true);
  Get.put(ProductRepository(), permanent: true);
  Get.put(CartController(), permanent: true);

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
