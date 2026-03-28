import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/utils/app_logger.dart';

class MapService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'CareLifeTouch/1.0';
  static const Duration _requestDelay = Duration(seconds: 1); // Rate limiting

  /// Map tiles URL for OpenStreetMap
  static const String mapTilesUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Get address from latitude and longitude (Reverse Geocoding)
  static Future<Map<String, dynamic>?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?lat=$latitude&lon=$longitude&format=json',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await Future.delayed(_requestDelay);
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error in reverseGeocode: $e');
      return null;
    }
  }

  /// Search for addresses based on query
  static Future<List<Map<String, dynamic>>> searchAddress({
    required String query,
    String countryCode = 'bd',
  }) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/search?q=${Uri.encodeComponent(query)}&format=json&countrycodes=$countryCode',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await Future.delayed(_requestDelay);
        final List<dynamic> results = jsonDecode(response.body) as List<dynamic>;
      return results
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    return [];
  } catch (e) {
    AppLogger.error('Error in searchAddress: $e');
    return [];
    }
  }

  /// Get map tile URL for a specific zoom, x, y
  static String getMapTileUrl(int z, int x, int y) {
    return mapTilesUrl
        .replaceAll('{z}', z.toString())
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString());
  }
}


