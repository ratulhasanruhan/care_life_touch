import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../models/api_exception.dart';
import 'storage_provider.dart';

/// Base API Provider
/// This handles all HTTP requests
class ApiProvider extends GetConnect {
  late final StorageService _storage;

  @override
  void onInit() {
    _storage = Get.find<StorageService>();
    httpClient.baseUrl = AppConstants.baseUrl;
    httpClient.timeout = Duration(
      milliseconds: AppConstants.connectionTimeout,
    );
    httpClient.followRedirects = true;
    httpClient.maxAuthRetries = 1;

    httpClient.addRequestModifier<dynamic>((request) {
      AppLogger.api(request.method, request.url.toString());
      request.headers['Accept'] = 'application/json';

      if (!request.headers.containsKey('Content-Type')) {
        request.headers['Content-Type'] = 'application/json';
      }

      final token = _storage.getToken();
      if (token != null && token.trim().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      return request;
    });

    httpClient.addResponseModifier((request, response) {
      final statusCode = response.statusCode ?? -1;
      if (statusCode >= 200 && statusCode < 300) {
        AppLogger.success('API ${request.method} $statusCode');
      } else {
        AppLogger.warning('API ${request.method} $statusCode');
      }

      return response;
    });

    super.onInit();
  }

  Future<dynamic> getData(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    return _runRequest(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      query: query,
      invoke: () => get<dynamic>(endpoint, query: query, headers: headers),
    );
  }

  Future<dynamic> postData(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _runRequest(
      method: 'POST',
      endpoint: endpoint,
      headers: headers,
      body: body,
      invoke: () => post<dynamic>(endpoint, body, headers: headers),
    );
  }

  Future<dynamic> putData(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _runRequest(
      method: 'PUT',
      endpoint: endpoint,
      headers: headers,
      body: body,
      invoke: () => put<dynamic>(endpoint, body, headers: headers),
    );
  }

  Future<dynamic> deleteData(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _runRequest(
      method: 'DELETE',
      endpoint: endpoint,
      headers: headers,
      invoke: () => delete<dynamic>(endpoint, headers: headers),
    );
  }

  Future<dynamic> uploadFile(
    String endpoint, {
    required File file,
    String fieldName = 'image',
    Map<String, String>? headers,
  }) async {
    final formData = FormData({
      fieldName: MultipartFile(file, filename: file.uri.pathSegments.last),
    });

    final uploadHeaders = <String, String>{...?headers};
    uploadHeaders.remove('Content-Type');

    return _runRequest(
      method: 'POST',
      endpoint: endpoint,
      headers: uploadHeaders,
      invoke: () => post<dynamic>(endpoint, formData, headers: uploadHeaders),
    );
  }

  Future<dynamic> _runRequest({
    required String method,
    required String endpoint,
    required Future<Response<dynamic>> Function() invoke,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    var attempt = 0;

    while (true) {
      try {
        final response = await invoke();
        return _normalizeResponse(response);
      } on ApiException catch (error, stackTrace) {
        if (_shouldRetry(method, error.statusCode, attempt)) {
          attempt++;
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
          continue;
        }
        AppLogger.error('$method $endpoint failed', error, stackTrace);
        rethrow;
      } on TimeoutException catch (error, stackTrace) {
        if (_shouldRetry(method, null, attempt)) {
          attempt++;
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
          continue;
        }
        AppLogger.error('$method $endpoint timed out', error, stackTrace);
        throw const ApiException('The request timed out. Please try again.');
      } on SocketException catch (error, stackTrace) {
        if (_shouldRetry(method, null, attempt)) {
          attempt++;
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
          continue;
        }
        AppLogger.error('$method $endpoint network failure', error, stackTrace);
        throw const ApiException(
          'Unable to reach the server. Check your internet connection and try again.',
        );
      } catch (error, stackTrace) {
        AppLogger.error('$method $endpoint unexpected failure', error, stackTrace);
        if (error is ApiException) {
          rethrow;
        }
        throw ApiException(
          'Something went wrong while contacting the server.',
          details: {
            'method': method,
            'endpoint': endpoint,
            'query': query,
            'headers': headers,
            'body': body,
          },
        );
      }
    }
  }

  bool _shouldRetry(String method, int? statusCode, int attempt) {
    if (attempt >= AppConstants.maxRequestRetries) {
      return false;
    }

    final normalized = method.toUpperCase();
    if (normalized != 'GET') {
      return false;
    }

    return statusCode == null || statusCode >= 500;
  }

  dynamic _normalizeResponse(Response<dynamic> response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (response.hasError || statusCode == null || statusCode < 200 || statusCode >= 300) {
      throw ApiException(
        _extractMessage(body, response.bodyString) ?? 'Request failed.',
        statusCode: statusCode,
        details: body ?? response.bodyString,
      );
    }

    if (body is Map) {
      final map = _toStringKeyedMap(body);
      if (map['success'] == false) {
        throw ApiException(
          _extractMessage(map, response.bodyString) ?? 'Request failed.',
          statusCode: statusCode,
          details: map,
        );
      }
      return map;
    }

    if (body is List) {
      return body;
    }

    if (response.bodyString != null && response.bodyString!.trim().isNotEmpty) {
      return response.bodyString;
    }

    return body;
  }

  Map<String, dynamic> _toStringKeyedMap(Map source) {
    return source.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }

  String? _extractMessage(dynamic body, String? bodyString) {
    if (body is Map) {
      final map = _toStringKeyedMap(body);
      for (final key in const ['message', 'error', 'details']) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }

      final nestedKeys = ['data', 'errors'];
      for (final key in nestedKeys) {
        final nested = map[key];
        if (nested is Map) {
          final nestedMessage = _extractMessage(nested, bodyString);
          if (nestedMessage != null) {
            return nestedMessage;
          }
        }
      }
    }

    if (bodyString != null && bodyString.trim().isNotEmpty) {
      return bodyString.trim();
    }

    return null;
  }
}
