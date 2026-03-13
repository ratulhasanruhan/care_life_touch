import 'dart:io';

import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../models/api_exception.dart';
import '../providers/api_provider.dart';

class AuthRepository {
  AuthRepository({ApiProvider? apiProvider})
    : _api = apiProvider ??
          (Get.isRegistered<ApiProvider>()
              ? Get.find<ApiProvider>()
              : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _api.postData(
      '/login-account',
      body: {
        'identifier': identifier.trim(),
        'password': password,
      },
    );

    return _normalizeSession(response);
  }

  Future<Map<String, dynamic>> registerBuyer({
    required String shopName,
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? drugLicense,
    String? tradeLicense,
    String? nidImage,
    List<String>? shopImages,
  }) async {
    final response = await _api.postData(
      '/register-buyer',
      body: {
        'shopName': shopName.trim(),
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        'password': password,
        if (drugLicense != null && drugLicense.isNotEmpty)
          'drugLicense': drugLicense,
        if (tradeLicense != null && tradeLicense.isNotEmpty)
          'tradeLicense': tradeLicense,
        if (nidImage != null && nidImage.isNotEmpty) 'nidImage': nidImage,
        if (shopImages != null && shopImages.isNotEmpty) 'shopImages': shopImages,
      },
    );

    return _asMap(response);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String accountId,
    required String otp,
  }) async {
    final response = await _api.postData(
      '/verify-otp',
      body: {
        'accountId': accountId,
        'otp': otp,
      },
    );

    return _asMap(response);
  }

  Future<void> sendForgotPasswordOtp({required String identifier}) async {
    await _api.postData(
      '/send-forgot-password-otp',
      body: {'identifier': identifier.trim()},
    );
  }

  Future<void> resetPasswordWithOtp({
    required String identifier,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.postData(
      '/reset-password-with-otp',
      body: {
        'identifier': identifier.trim(),
        'otp': otp.trim(),
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<Map<String, dynamic>> accessMe() async {
    final response = await _api.getData('/access-me');
    final map = _asMap(response);

    final user = _extractUserMap(map);
    if (user != null) {
      return user;
    }

    return map;
  }

  Future<void> logout() async {
    try {
      await _api.postData('/auth/logout');
    } on ApiException catch (error) {
      if (error.statusCode != null && error.statusCode! >= 500) {
        rethrow;
      }
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.putData(
      '/buyer-change-password',
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> updateBuyerProfile({
    required String shopName,
    required String fullName,
    String? drugLicense,
    String? tradeLicense,
    String? nidImage,
    List<String>? shopImages,
  }) async {
    final response = await _api.putData(
      '/update-buyer-profile',
      body: {
        'shopName': shopName.trim(),
        'fullName': fullName.trim(),
        if (drugLicense != null && drugLicense.isNotEmpty)
          'drugLicense': drugLicense,
        if (tradeLicense != null && tradeLicense.isNotEmpty)
          'tradeLicense': tradeLicense,
        if (nidImage != null && nidImage.isNotEmpty) 'nidImage': nidImage,
        if (shopImages != null && shopImages.isNotEmpty) 'shopImages': shopImages,
      },
    );

    return _asMap(response);
  }

  Future<String> uploadImage(File file) async {
    final response = await _api.uploadFile(
      AppConstants.uploadEndpoint,
      file: file,
    );

    final map = _asMap(response);
    final imageUrl = _extractString(
      map,
      const [
        'url',
        'image',
        'path',
        'imageUrl',
        'secureUrl',
        'location',
      ],
    );

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl;
    }

    final nestedData = _firstNestedMap(map, const ['data', 'result', 'file']);
    final nestedUrl = nestedData == null
        ? null
        : _extractString(
            nestedData,
            const [
              'url',
              'image',
              'path',
              'imageUrl',
              'secureUrl',
              'location',
            ],
          );

    if (nestedUrl != null && nestedUrl.isNotEmpty) {
      return nestedUrl;
    }

    throw const ApiException('Image upload succeeded but no image URL was returned.');
  }

  Map<String, dynamic> _normalizeSession(dynamic response) {
    final map = _asMap(response);
    final token = _extractToken(map);
    final user = _extractUserMap(map) ?? <String, dynamic>{};

    if (token == null || token.isEmpty) {
      throw ApiException(
        'Login succeeded but no access token was returned by the server.',
        details: map,
      );
    }

    return {
      'token': token,
      'user': user,
      'raw': map,
    };
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return response.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    throw ApiException(
      'Unexpected server response format.',
      details: response,
    );
  }

  String? _extractToken(Map<String, dynamic> data) {
    final directToken = _extractString(
      data,
      const [
        'token',
        'accessToken',
        'access_token',
        'jwt',
        'bearerToken',
      ],
    );
    if (directToken != null && directToken.isNotEmpty) {
      return directToken;
    }

    final nestedData = _firstNestedMap(data, const ['data', 'result', 'session']);
    if (nestedData != null) {
      return _extractString(
        nestedData,
        const [
          'token',
          'accessToken',
          'access_token',
          'jwt',
          'bearerToken',
        ],
      );
    }

    return null;
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> data) {
    for (final key in const ['user', 'buyer', 'account', 'profile']) {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.map(
          (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
        );
      }
    }

    final nested = _firstNestedMap(data, const ['data', 'result']);
    if (nested != null) {
      for (final key in const ['user', 'buyer', 'account', 'profile']) {
        final value = nested[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
        if (value is Map) {
          return value.map(
            (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
          );
        }
      }

      if (nested.containsKey('_id') || nested.containsKey('id')) {
        return nested;
      }
    }

    if (data.containsKey('_id') || data.containsKey('id')) {
      return data;
    }

    return null;
  }

  Map<String, dynamic>? _firstNestedMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.map(
          (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
        );
      }
    }
    return null;
  }

  String? _extractString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

