import 'package:get/get.dart';
import '../bindings/address_binding.dart';
import '../views/address_list_view.dart';
import '../views/add_address_view.dart';

abstract class AddressRoutes {
  static const addresses = '/addresses';
  static const addAddress = '/addresses/add';
}

class AddressPages {
  static final pages = [
    GetPage(
      name: AddressRoutes.addresses,
      page: () => const AddressListView(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: AddressRoutes.addAddress,
      page: () => const AddAddressView(),
      binding: AddressBinding(),
    ),
  ];
}

