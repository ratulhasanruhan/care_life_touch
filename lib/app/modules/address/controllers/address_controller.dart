import 'dart:async';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/address_model.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../services/map_service.dart';
import '../views/routes.dart';

class AddressController extends GetxController {
  late final AddressRepository addressRepository;
  late final StorageService storageService;

  /// Address list
  final addresses = <AddressModel>[].obs;

  /// Current selected address
  final selectedAddress = Rxn<AddressModel>();

  /// Loading state
  final isLoading = false.obs;
  final isGettingLocation = false.obs;
  final isSearching = false.obs;

  /// Current latitude & longitude
  final currentLat = 0.0.obs;
  final currentLng = 0.0.obs;

  /// Location status
  final locationStatus = 'Choose location'.obs;
  final hasLocationError = false.obs;

  /// Search results
  final searchResults = <Map<String, dynamic>>[].obs;

  /// Form fields
  final selectedAddressType = 'Home'.obs; // Home, Office, Other
  final profileName = ''.obs;
  final profilePhone = ''.obs;
  final addressText = ''.obs;
  final editingAddressId = RxnString();
  final isEditMode = false.obs;
  bool _formHydrated = false;

  bool _locationBootstrapped = false;

  @override
  void onInit() {
    super.onInit();
    addressRepository = Get.find<AddressRepository>();
    storageService = Get.find<StorageService>();
    _loadProfileIdentity();
    loadAddresses();
  }

  void ensureLocationBootstrapped() {
    if (_locationBootstrapped) return;
    _locationBootstrapped = true;
    getCurrentLocation();
  }

  /// Load saved addresses
  Future<void> loadAddresses() async {
    isLoading.value = true;
    try {
      final fetchedAddresses = await addressRepository.getMyAddresses();
      addresses.assignAll(fetchedAddresses);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load addresses');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      isGettingLocation.value = true;
      hasLocationError.value = false;
      locationStatus.value = 'Getting location...';

      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          hasLocationError.value = true;
          locationStatus.value = 'Location permission denied';
          Get.snackbar('Permission', 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        hasLocationError.value = true;
        locationStatus.value = 'Location permission denied';
        Get.snackbar('Error', 'Enable location permissions in app settings');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      ).timeout(
        const Duration(seconds: 35),
        onTimeout: () {
          throw TimeoutException('Location request timed out');
        },
      );

      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
      locationStatus.value = 'Location found';
      hasLocationError.value = false;

      AppLogger.success('Location obtained: ${position.latitude}, ${position.longitude}');

      // Get address from coordinates
      await getReverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      hasLocationError.value = true;
      locationStatus.value = 'Failed to get location';
      AppLogger.error('Failed to get location', e);
      Get.snackbar('Error', 'Failed to get location: $e');
    } finally {
      isGettingLocation.value = false;
    }
  }

  /// Reverse geocoding (lat/lng to address)
  Future<void> getReverseGeocode(double lat, double lng) async {
    try {
      isLoading.value = true;
      locationStatus.value = 'Resolving address...';

      final response = await MapService.reverseGeocode(latitude: lat, longitude: lng);

      if (response != null) {
        final displayName = (response['display_name'] ?? '').toString();
        if (displayName.isNotEmpty) {
          addressText.value = displayName;
          locationStatus.value = displayName;
          hasLocationError.value = false;
          AppLogger.success('Address resolved: $displayName');
        } else {
          throw Exception('No address found for coordinates');
        }
      } else {
        throw Exception('Failed to resolve address');
      }
    } catch (e) {
      hasLocationError.value = true;
      locationStatus.value = 'Failed to get address';
      AppLogger.error('Failed to get address', e);
      Get.snackbar('Error', 'Failed to resolve address: $e');
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
      isSearching.value = true;
      isLoading.value = true;

      final results = await MapService.searchAddress(
        query: query,
        countryCode: 'bd',
      );

      searchResults.assignAll(results);

      if (results.isEmpty) {
        Get.snackbar('Info', 'No addresses found matching your query');
      }

      AppLogger.info('Search results: ${results.length} addresses found');
    } catch (e) {
      AppLogger.error('Failed to search address', e);
      Get.snackbar('Error', 'Failed to search address: $e');
    } finally {
      isSearching.value = false;
      isLoading.value = false;
    }
  }

  /// Save new address
  Future<void> saveAddress() async {
    if (addressText.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;

      final coordinates = [currentLng.value, currentLat.value];
      final hasValidCoordinates = currentLat.value != 0.0 || currentLng.value != 0.0;
      final payloadCoordinates = hasValidCoordinates ? coordinates : const [90.4125, 23.8103];

      final isEditing = isEditMode.value && editingAddressId.value != null;
      final AddressModel saved;

      if (isEditing) {
        saved = await addressRepository.updateAddress(
          addressId: editingAddressId.value!,
          addressType: selectedAddressType.value,
          fullAddress: addressText.value,
          formattedAddress: addressText.value,
          coordinates: payloadCoordinates,
        );

        final index = addresses.indexWhere((addr) => addr.id == saved.id);
        if (index != -1) {
          addresses[index] = saved;
          addresses.refresh();
        }
      } else {
        saved = await addressRepository.addAddress(
          addressType: selectedAddressType.value,
          fullAddress: addressText.value,
          formattedAddress: addressText.value,
          coordinates: payloadCoordinates,
        );
        addresses.insert(0, saved);
      }

      await loadAddresses();

      clearForm();
      Get.back(result: saved);
      Get.snackbar('Success', isEditing ? 'Address updated successfully' : 'Address saved successfully');
    } catch (_) {
      Get.snackbar('Error', isEditMode.value ? 'Failed to update address' : 'Failed to save address');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      isLoading.value = true;
      await addressRepository.setDefaultAddress(addressId);

      final updated = addresses
          .map((addr) => AddressModel(
                id: addr.id,
                addressType: addr.addressType,
                fullAddress: addr.fullAddress,
                formattedAddress: addr.formattedAddress,
                isDefault: addr.id == addressId,
                coordinates: addr.coordinates,
              ))
          .toList();
      addresses.assignAll(updated);
      addresses.sort((a, b) => (b.isDefault ? 1 : 0).compareTo(a.isDefault ? 1 : 0));

      Get.snackbar('Success', 'Default address updated');
    } catch (_) {
      Get.snackbar('Error', 'Failed to set default address');
    } finally {
      isLoading.value = false;
    }
  }

  /// Edit address
  void editAddress(AddressModel address) {
    editingAddressId.value = address.id;
    isEditMode.value = true;

    addressText.value = address.details;
    selectedAddressType.value = address.addressType;
    if (address.coordinates.length >= 2) {
      currentLng.value = address.coordinates[0];
      currentLat.value = address.coordinates[1];
    }
    locationStatus.value = address.details;

    Get.toNamed(AddressRoutes.addAddress, arguments: {'address': address});
  }

  void hydrateFormFromArguments() {
    if (_formHydrated) {
      return;
    }
    _formHydrated = true;

    final args = Get.arguments;
    if (args is Map && args['address'] is AddressModel) {
      final address = args['address'] as AddressModel;
      editingAddressId.value = address.id;
      isEditMode.value = true;
      addressText.value = address.details;
      selectedAddressType.value = address.addressType;
      if (address.coordinates.length >= 2) {
        currentLng.value = address.coordinates[0];
        currentLat.value = address.coordinates[1];
      }
      locationStatus.value = address.details;
      return;
    }

    clearForm();
  }

  /// Clear form
  void clearForm() {
    addressText.value = '';
    selectedAddressType.value = 'Home';
    currentLat.value = 0.0;
    currentLng.value = 0.0;
    searchResults.clear();
    editingAddressId.value = null;
    isEditMode.value = false;
    _formHydrated = false;
  }

  /// Select address type
  void selectAddressType(String type) {
    selectedAddressType.value = type;
  }

  void setManualLocation(double lat, double lng) {
    currentLat.value = lat;
    currentLng.value = lng;
    locationStatus.value = 'Resolving address...';
    getReverseGeocode(lat, lng);
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;
      // TODO: wire delete API when endpoint is available.
      addresses.removeWhere((addr) => addr.id == addressId);
      Get.snackbar('Success', 'Address deleted');
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete address');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadProfileIdentity() {
    final user = storageService.getUser() ?? const <String, dynamic>{};
    profileName.value = _firstNonEmptyString([
          user['name'],
          user['fullName'],
          user['ownerName'],
          user['shopName'],
        ]) ??
        'Your profile';
    profilePhone.value = _firstNonEmptyString([
          user['phone'],
          user['phoneNumber'],
          user['mobile'],
        ]) ??
        '';
  }

  String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }
}
