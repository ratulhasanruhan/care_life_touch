import 'package:get/get.dart';
import '../../core/utils/app_logger.dart';

/// Base API Provider
/// This handles all HTTP requests
class ApiProvider extends GetConnect {
  @override
  void onInit() {
    // Configure base URL
    httpClient.baseUrl = 'https://api.example.com/api/v1';

    // Configure timeout
    httpClient.timeout = const Duration(seconds: 30);

    // Add request interceptor
    httpClient.addRequestModifier<dynamic>((request) {
      // Log request
      AppLogger.api(request.method, request.url.toString());

      // Add headers
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      // Add auth token if available
      // final token = Get.find<StorageService>().getToken();
      // if (token != null) {
      //   request.headers['Authorization'] = 'Bearer $token';
      // }

      return request;
    });

    // Add response interceptor
    httpClient.addResponseModifier((request, response) {
      // Log response
      if (response.statusCode == 200) {
        AppLogger.success('API ${request.method} ${response.statusCode}');
      } else {
        AppLogger.warning('API ${request.method} ${response.statusCode}');
      }

      return response;
    });

    super.onInit();
  }

  /// GET request
  Future<Response<T>> getData<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await get<T>(endpoint, query: query, headers: headers);
    } catch (e, stackTrace) {
      AppLogger.error('GET $endpoint failed', e, stackTrace);
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> postData<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      return await post<T>(endpoint, body, headers: headers);
    } catch (e, stackTrace) {
      AppLogger.error('POST $endpoint failed', e, stackTrace);
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> putData<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      return await put<T>(endpoint, body, headers: headers);
    } catch (e, stackTrace) {
      AppLogger.error('PUT $endpoint failed', e, stackTrace);
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> deleteData<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      return await delete<T>(endpoint, headers: headers);
    } catch (e, stackTrace) {
      AppLogger.error('DELETE $endpoint failed', e, stackTrace);
      rethrow;
    }
  }
}
