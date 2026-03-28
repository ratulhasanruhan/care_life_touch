import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../services/map_service.dart';

class AddressController extends GetxController {
  late final AddressRepository addressRepository;

  /// Address list
  final addresses = <AddressModel>[].obs;

  /// Current selected address
  final selectedAddress = Rxn<AddressModel>();

  /// Loading state
  final isLoading = false.obs;

  /// Current latitude & longitude
  final currentLat = 0.0.obs;
  final currentLng = 0.0.obs;

  /// Search results
  final searchResults = <Map<String, dynamic>>[].obs;

  /// Form fields
  final selectedAddressType = 'Home'.obs; // Home, Office, Other
  final recipientName = ''.obs;
  final recipientPhone = ''.obs;
  final addressText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    addressRepository = Get.find<AddressRepository>();
    loadAddresses();
  }

  /// Load saved addresses
  void loadAddresses() {
    isLoading.value = true;
    try {
      // TODO: Load from API/database
      addresses.value = [];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load addresses');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          Get.snackbar('Permission', 'Location permission denied');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLat.value = position.latitude;
      currentLng.value = position.longitude;

      // Get address from coordinates
      await getReverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location');
    } finally {
      isLoading.value = false;
    }
  }

  /// Reverse geocoding (lat/lng to address)
  Future<void> getReverseGeocode(double lat, double lng) async {
    try {
      isLoading.value = true;

      // TODO: Call Nominatim reverse API
      // https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lon}&format=json

      // Example:
      // final response = await http.get(
      //   Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json'),
      //   headers: {'User-Agent': 'CareLifeTouch/1.0'},
      // );
    } catch (e) {
      Get.snackbar('Error', 'Failed to get address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search address by query
  Future<void> searchAddress(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;

      final results = await MapService.searchAddress(
        query: query,
        countryCode: 'bd',
      );

      searchResults.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Failed to search address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Save new address
  Future<void> saveAddress() async {
    if (recipientName.isEmpty || recipientPhone.isEmpty || addressText.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;

      final newAddress = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        addressType: selectedAddressType.value,
        fullAddress: addressText.value,
        formattedAddress: addressText.value,
        isDefault: addresses.isEmpty,
        coordinates: [currentLng.value, currentLat.value],
      );

      // TODO: Save to API/database
      addresses.add(newAddress);

      // Clear form
      clearForm();

      Get.back();
      Get.snackbar('Success', 'Address saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;

      // TODO: Delete from API using addressRepository
      // await addressRepository.deleteAddress(addressId);

      addresses.removeWhere((addr) => addr.id == addressId);

      Get.snackbar('Success', 'Address deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Edit address
  void editAddress(AddressModel address) {
    recipientName.value = address.fullAddress.split(',').first;
    recipientPhone.value = '';
    addressText.value = address.fullAddress;
    selectedAddressType.value = address.addressType;
    if (address.coordinates.length >= 2) {
      currentLng.value = address.coordinates[0];
      currentLat.value = address.coordinates[1];
    }
    // Navigate to add address screen with edit mode
  }

  /// Clear form
  void clearForm() {
    recipientName.value = '';
    recipientPhone.value = '';
    addressText.value = '';
    selectedAddressType.value = 'Home';
    currentLat.value = 0.0;
    currentLng.value = 0.0;
    searchResults.clear();
  }

  /// Select address type
  void selectAddressType(String type) {
    selectedAddressType.value = type;
  }
}








