import 'package:get/get.dart';

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
      // Handle response modifications if needed
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
    } catch (e) {
      throw _handleError(e);
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
    } catch (e) {
      throw _handleError(e);
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
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> deleteData<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      return await delete<T>(endpoint, headers: headers);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle errors
  String _handleError(dynamic error) {
    if (error is Exception) {
      return 'Network error occurred';
    }
    return 'An unexpected error occurred';
  }
}

