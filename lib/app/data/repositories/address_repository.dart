import 'dart:convert';

import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../models/address_model.dart';
import '../models/api_exception.dart';
import '../providers/api_provider.dart';
import '../providers/storage_provider.dart';

class AddressRepository {
  AddressRepository({ApiProvider? apiProvider})
      : _api = apiProvider ??
            (Get.isRegistered<ApiProvider>()
                ? Get.find<ApiProvider>()
                : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  /// Runs once per login session after registration: if GPS was cached and the account
  /// has no addresses yet, creates Home. Skipped entirely after [AppConstants.keyRegistrationAddressBootstrapCompleted].
  Future<void> ensureBootstrapAddressFromRegistrationCache(
    StorageService storage,
  ) async {
    if (!storage.isLoggedIn) return;

    if (storage.read<bool>(
          AppConstants.keyRegistrationAddressBootstrapCompleted,
        ) ==
        true) {
      return;
    }

    Future<void> markDone() async {
      await storage.write(
        AppConstants.keyRegistrationAddressBootstrapCompleted,
        true,
      );
    }

    final cachedRaw = storage.read<String>(
      AppConstants.keyPendingRegistrationLocation,
    );
    if (cachedRaw == null || cachedRaw.trim().isEmpty) {
      await markDone();
      return;
    }

    Map<String, dynamic>? map;
    try {
      final decoded = jsonDecode(cachedRaw);
      if (decoded is Map) {
        map = decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      AppLogger.warning('Invalid pending_registration_location JSON');
      await storage.remove(AppConstants.keyPendingRegistrationLocation);
      await markDone();
      return;
    }
    if (map == null) {
      await storage.remove(AppConstants.keyPendingRegistrationLocation);
      await markDone();
      return;
    }

    final lat = _readDouble(map['latitude']);
    final lng = _readDouble(map['longitude']);
    if (lat == null || lng == null) {
      await storage.remove(AppConstants.keyPendingRegistrationLocation);
      await markDone();
      return;
    }

    try {
      final existing = await getMyAddresses();
      if (existing.isNotEmpty) {
        await storage.remove(AppConstants.keyPendingRegistrationLocation);
        await markDone();
        return;
      }

      var full = map['address']?.toString().trim() ?? '';
      if (full.isEmpty || full.toLowerCase() == 'null') {
        full = '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      }

      await addAddress(
        addressType: 'Home',
        fullAddress: full,
        formattedAddress: full,
        coordinates: [lng, lat],
      );

      await storage.remove(AppConstants.keyPendingRegistrationLocation);
      await markDone();
      AppLogger.info('Created default address from cached registration location');
    } catch (error, stackTrace) {
      AppLogger.error(
        'ensureBootstrapAddressFromRegistrationCache failed',
        error,
        stackTrace,
      );
    }
  }

  double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return double.tryParse(text);
  }

  Future<List<AddressModel>> getMyAddresses() async {
    final response = await _api.getData('/get-my-addresses');
    final envelope = _asMap(response);
    final data = _firstMap(envelope, const ['data', 'result']) ?? envelope;
    final addressesRaw = data['addresses'] ?? data['items'] ?? data['data'] ?? envelope['addresses'];

    if (addressesRaw is List) {
      return addressesRaw
          .map(_toMap)
          .whereType<Map<String, dynamic>>()
          .map(AddressModel.fromJson)
          .toList();
    }

    if (data.containsKey('_id') || data.containsKey('id')) {
      return [AddressModel.fromJson(data)];
    }

    return const [];
  }

  Future<AddressModel> addAddress({
    required String addressType,
    required String fullAddress,
    required List<double> coordinates,
    String? formattedAddress,
  }) async {
    final response = await _api.postData(
      '/add-address',
      body: {
        'addressType': addressType,
        'location': {
          'type': 'Point',
          'coordinates': coordinates,
          if (formattedAddress != null && formattedAddress.trim().isNotEmpty)
            'formattedAddress': formattedAddress.trim(),
        },
        'fullAddress': fullAddress.trim(),
      },
    );

    return _extractAddress(response);
  }

  Future<AddressModel> updateAddress({
    required String addressId,
    required String addressType,
    required String fullAddress,
    required List<double> coordinates,
    String? formattedAddress,
  }) async {
    final response = await _api.putData(
      '/update-address/$addressId',
      body: {
        'addressType': addressType,
        'location': {
          'type': 'Point',
          'coordinates': coordinates,
          if (formattedAddress != null && formattedAddress.trim().isNotEmpty)
            'formattedAddress': formattedAddress.trim(),
        },
        'fullAddress': fullAddress.trim(),
      },
    );

    return _extractAddress(response);
  }

  Future<void> setDefaultAddress(String addressId) async {
    await _api.putData('/set-default-address/$addressId');
  }

  AddressModel _extractAddress(dynamic response) {
    final map = _asMap(response);
    final data = _firstMap(map, const ['address', 'data', 'result']) ?? map;
    if (data.containsKey('_id') || data.containsKey('id')) {
      return AddressModel.fromJson(data);
    }
    throw ApiException('Unexpected address response format.', details: response);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    final map = _toMap(value);
    if (map != null) {
      return map;
    }
    throw ApiException('Unexpected response format.', details: value);
  }

  Map<String, dynamic>? _firstMap(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final mapped = _toMap(source[key]);
      if (mapped != null) {
        return mapped;
      }
    }
    return null;
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}

