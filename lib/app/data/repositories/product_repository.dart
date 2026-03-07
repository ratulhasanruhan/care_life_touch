import '../../modules/home/models/product_model.dart';

class ProductRepository {
  Future<List<ProductModel>> getAllProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return [
      _item(0, 'Paracetamol 500 Mg', 'ACME Pharmaceuticals', 'assets/demo/product_1.png', true),
      _item(1, 'Ibuprofen Tablet', 'Opsonin Pharmaceuticals', 'assets/demo/product_2.png', false),
      _item(2, 'Azithromycin Capsule', 'Incepta Pharmaceuticals', 'assets/demo/product_1.png', true),
      _item(3, 'Napa Extra Tablet', 'ACME Pharmaceuticals', 'assets/demo/product_2.png', false),
      _item(4, 'Vitamin C Capsule', 'Aristopharma Pharmaceuticals', 'assets/demo/product_1.png', true),
      _item(5, 'Cefixime Tablet', 'Opsonin Pharmaceuticals', 'assets/demo/product_2.png', false),
      _item(6, 'Amoxicillin Capsule', 'Incepta Pharmaceuticals', 'assets/demo/product_1.png', true),
      _item(7, 'Calcium Tablet', 'ACME Pharmaceuticals', 'assets/demo/product_2.png', false),
      _item(8, 'Pain Relief Capsule', 'Aristopharma Pharmaceuticals', 'assets/demo/product_1.png', false),
      _item(9, 'Cough Syrup Tablet', 'Opsonin Pharmaceuticals', 'assets/demo/product_2.png', true),
    ];
  }

  ProductModel _item(
    int i,
    String name,
    String brand,
    String image,
    bool offer,
  ) {
    return ProductModel(
      id: 'listing_product_$i',
      name: name,
      brand: brand,
      price: 100,
      maxPrice: 150,
      moq: '20 Box',
      rating: 4.9,
      imagePath: image,
      hasOffer: offer,
      offerLabel: offer ? 'SALE' : null,
    );
  }
}

