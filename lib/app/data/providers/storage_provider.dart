import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart'; // TODO: Run: flutter pub add get_storage
import 'package:shared_preferences/shared_preferences.dart';

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
    await write('auth_token', token);
  }

  /// Get auth token
  String? getToken() {
    return read<String>('auth_token');
  }

  /// Remove auth token
  Future<void> removeToken() async {
    await remove('auth_token');
  }

  /// Check if user is logged in
  bool get isLoggedIn => hasData('auth_token');

  /// Save user data
  Future<void> saveUser(Map<String, dynamic> user) async {
    await write('user_data', user);
  }

  /// Get user data
  Map<String, dynamic>? getUser() {
    return read<Map<String, dynamic>>('user_data');
  }

  /// Remove user data
  Future<void> removeUser() async {
    await remove('user_data');
  }

  /// Logout - Clear auth data
  Future<void> logout() async {
    await removeToken();
    await removeUser();
  }
}
