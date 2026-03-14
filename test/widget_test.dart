// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:care_life_touch/app/core/constants/app_constants.dart';
import 'package:care_life_touch/app/data/providers/api_provider.dart';
import 'package:care_life_touch/app/data/providers/storage_provider.dart';
import 'package:care_life_touch/app/data/models/cart_api_model.dart';
import 'package:care_life_touch/app/data/repositories/address_repository.dart';
import 'package:care_life_touch/app/data/repositories/auth_repository.dart';
import 'package:care_life_touch/app/data/repositories/cart_repository.dart';
import 'package:care_life_touch/app/data/repositories/order_repository.dart';
import 'package:care_life_touch/app/data/repositories/product_repository.dart';
import 'package:care_life_touch/app/modules/cart/controllers/cart_controller.dart';
import 'package:care_life_touch/app/modules/home/models/product_model.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:care_life_touch/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keyToken: 'test-token',
      AppConstants.keyOnboardingCompleted: true,
      AppConstants.keyUser: jsonEncode({
        'id': '1',
        'name': 'Test User',
        'ownerName': 'Test User',
        'shopName': 'Test Shop',
        'phone': '01700000000',
      }),
    });

    Get.reset();

    final storage = await StorageService().init();
    Get.put(storage, permanent: true);
    Get.put(ApiProvider(), permanent: true);
    Get.put(AuthRepository(), permanent: true);
    Get.put(AddressRepository(), permanent: true);
    Get.put<CartRepository>(_FakeCartRepository(), permanent: true);
    Get.put(OrderRepository(), permanent: true);
    Get.put<ProductRepository>(_FakeProductRepository(), permanent: true);
    Get.put(CartController(), permanent: true);
  });

  tearDown(Get.reset);

  testWidgets('App boots and main navigation tabs work', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('My Bag'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsWidgets);
    expect(find.text('Search Your Needs...'), findsOneWidget);
  });
}

class _FakeProductRepository extends ProductRepository {
  _FakeProductRepository();

  final List<ProductModel> _products = [
    ProductModel(
      id: 'p1',
      slug: 'paracetamol-500',
      defaultVariantId: 'v1',
      name: 'Paracetamol 500 Mg',
      brand: 'ACME Pharmaceuticals',
      description: 'Pain relief tablet',
      price: 100,
      maxPrice: 120,
      moq: '1 Box',
      imagePath: 'assets/demo/product_1.png',
      hasOffer: true,
      offerLabel: '20 OFF',
    ),
    ProductModel(
      id: 'p2',
      slug: 'napa-extra',
      defaultVariantId: 'v2',
      name: 'Napa Extra',
      brand: 'Beximco Pharma',
      description: 'Fast pain relief',
      price: 80,
      moq: '1 Box',
      imagePath: 'assets/demo/product_2.png',
    ),
  ];

  @override
  Future<List<ProductModel>> getAllProducts() async => _products;

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? subCategory,
    String? brand,
    String? query,
  }) async => _products;

  @override
  Future<List<ProductModel>> getDiscountedProducts() async =>
      _products.where((product) => product.hasOffer).toList();

  @override
  Future<Map<String, dynamic>> getFilterOptions() async => const {
        'brands': ['ACME Pharmaceuticals', 'Beximco Pharma'],
      };
}

class _FakeCartRepository extends CartRepository {
  _FakeCartRepository();

  @override
  Future<CartApiSnapshot> getCart() async => const CartApiSnapshot(
        items: [],
        subtotal: 0,
        discount: 0,
        deliveryFee: 0,
        total: 0,
      );

  @override
  Future<CartApiSnapshot> addToCart({
    required String productId,
    required String variantId,
    required int quantity,
  }) async => getCart();

  @override
  Future<CartApiSnapshot> updateCartItem({
    required String itemId,
    required int quantity,
  }) async => getCart();

  @override
  Future<CartApiSnapshot> removeCartItem(String itemId) async => getCart();

  @override
  Future<void> clearCart() async {}
}

