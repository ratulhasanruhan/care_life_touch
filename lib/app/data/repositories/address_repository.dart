import 'package:get/get.dart';

import '../models/address_model.dart';
import '../models/api_exception.dart';
import '../providers/api_provider.dart';

class AddressRepository {
  AddressRepository({ApiProvider? apiProvider})
      : _api = apiProvider ??
            (Get.isRegistered<ApiProvider>()
                ? Get.find<ApiProvider>()
                : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

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

