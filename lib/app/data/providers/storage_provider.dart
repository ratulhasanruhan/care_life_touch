import 'dart:convert';

import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart'; // TODO: Run: flutter pub add get_storage
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Local storage service using SharedPreferences
/// TODO: Replace with GetStorage after adding the package
class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  /// Write data to storage
  Future<void> write(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  /// Read data from storage
  T? read<T>(String key) {
    return _prefs.get(key) as T?;
  }

  /// Remove data from storage
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clear all storage
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// Check if key exists
  bool hasData(String key) {
    return _prefs.containsKey(key);
  }

  // Specific getters and setters for common data

  /// Save auth token
  Future<void> saveToken(String token) async {
    await write(AppConstants.keyToken, token);
  }

  /// Get auth token
  String? getToken() {
    return read<String>(AppConstants.keyToken);
  }

  /// Remove auth token
  Future<void> removeToken() async {
    await remove(AppConstants.keyToken);
  }

  /// Check if user is logged in
  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.trim().isNotEmpty;
  }

  /// Save user data
  Future<void> saveUser(Map<String, dynamic> user) async {
    await write(AppConstants.keyUser, jsonEncode(user));
  }

  /// Get user data
  Map<String, dynamic>? getUser() {
    final userJson = read<String>(AppConstants.keyUser);

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  /// Remove user data
  Future<void> removeUser() async {
    await remove(AppConstants.keyUser);
  }

  /// Save account ID
  Future<void> saveAccountId(String accountId) async {
    await write(AppConstants.keyAccountId, accountId);
  }

  /// Get account ID
  String? getAccountId() {
    return read<String>(AppConstants.keyAccountId);
  }

  /// Save reference ID
  Future<void> saveReferenceId(String referenceId) async {
    await write(AppConstants.keyReferenceId, referenceId);
  }

  /// Get reference ID
  String? getReferenceId() {
    return read<String>(AppConstants.keyReferenceId);
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await write(AppConstants.keyUserRole, role);
  }

  /// Get user role
  String? getUserRole() {
    return read<String>(AppConstants.keyUserRole);
  }

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
    String? accountId,
    String? referenceId,
    String? role,
  }) async {
    await saveToken(token);
    await saveUser(user);
    if (accountId != null && accountId.isNotEmpty) {
      await saveAccountId(accountId);
    }
    if (referenceId != null && referenceId.isNotEmpty) {
      await saveReferenceId(referenceId);
    }
    if (role != null && role.isNotEmpty) {
      await saveUserRole(role);
    }
  }

  Future<void> saveLastLoginIdentifier(String identifier) async {
    await write(AppConstants.keyLastLoginIdentifier, identifier);
  }

  String? getLastLoginIdentifier() {
    return read<String>(AppConstants.keyLastLoginIdentifier);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await write(AppConstants.keyOnboardingCompleted, completed);
  }

  bool get isOnboardingCompleted =>
      read<bool>(AppConstants.keyOnboardingCompleted) ?? false;

  /// Logout - Clear auth data
  Future<void> logout() async {
    await removeToken();
    await removeUser();
    await remove(AppConstants.keyAccountId);
    await remove(AppConstants.keyReferenceId);
    await remove(AppConstants.keyUserRole);
    await removePendingOTP();
  }

  /// Save pending OTP state (accountId waiting for OTP verification)
  Future<void> savePendingOTP({
    required String accountId,
    required String identifier,
  }) async {
    final otpData = {
      'accountId': accountId,
      'identifier': identifier,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await write('pending_otp', jsonEncode(otpData));
  }

  /// Get pending OTP state
  Map<String, dynamic>? getPendingOTP() {
    final otpJson = read<String>('pending_otp');
    if (otpJson == null || otpJson.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(otpJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Remove pending OTP state
  Future<void> removePendingOTP() async {
    await remove('pending_otp');
  }
}
