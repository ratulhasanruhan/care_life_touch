import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/helpers.dart';
import '../models/api_exception.dart';
import 'storage_provider.dart';
import '../../routes/app_pages.dart';

/// Base API Provider
/// This handles all HTTP requests
class ApiProvider extends GetConnect {
  late final StorageService _storage;
  bool _isHandlingUnauthorized = false;

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
      request.headers['Accept'] = 'application/json';

      final forceMultipart = request.headers.remove('X-Multipart') == 'true';
      final isMultipartRequest =
          forceMultipart || request.url.path.endsWith(AppConstants.uploadEndpoint);

      if (!request.headers.containsKey('Content-Type') && !isMultipartRequest) {
        request.headers['Content-Type'] = 'application/json';
      }

      final token = _storage.getToken();
      if (token != null && token.isNotEmpty) {
        // Set both Cookie header and authorization header for compatibility
        request.headers['Cookie'] = 'buyer_token=$token; Path=/';
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

      // Extract token from Set-Cookie header
      try {
        var setCookieHeader = response.headers?['set-cookie'] ?? response.headers?['Set-Cookie'];
        if (setCookieHeader != null) {
          final cookieString = setCookieHeader is List
              ? (setCookieHeader.isNotEmpty ? setCookieHeader[0] : null)
              : setCookieHeader.toString();

          if (cookieString != null && cookieString.contains('buyer_token=')) {
            final tokenPart = cookieString.split(';')[0].trim();
            final token = tokenPart.substring('buyer_token='.length).trim();
            if (token.isNotEmpty) {
              _storage.saveToken(token);
            }
          }
        }
      } catch (e) {
        // Silent
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
    final normalizedQuery = _normalizeQuery(query);
    return _runRequest(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      query: normalizedQuery,
      invoke: () => get<dynamic>(endpoint, query: normalizedQuery, headers: headers),
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

  Map<String, dynamic>? _normalizeQuery(Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) {
      return null;
    }

    final normalized = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;

      if (value is Iterable) {
        final items = value
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList(growable: false);
        if (items.isNotEmpty) {
          normalized[key] = items;
        }
        return;
      }

      normalized[key] = value.toString();
    });

    return normalized.isEmpty ? null : normalized;
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

  Future<dynamic> patchData(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _runRequest(
      method: 'PATCH',
      endpoint: endpoint,
      headers: headers,
      body: body,
      invoke: () => patch<dynamic>(endpoint, body, headers: headers),
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
    String? fileName,
    String? contentType,
    Map<String, String>? headers,
  }) async {
    final multipart = contentType == null
        ? MultipartFile(
            file,
            filename: fileName ?? file.uri.pathSegments.last,
          )
        : MultipartFile(
            file,
            filename: fileName ?? file.uri.pathSegments.last,
            contentType: contentType,
          );

    final formData = FormData({
      fieldName: multipart,
    });

    final uploadHeaders = <String, String>{...?headers};
    uploadHeaders.remove('Content-Type');
    uploadHeaders['X-Multipart'] = 'true';

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
        if ((response.statusCode ?? 0) == 401) {
          _handleUnauthorized();
        }
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
      if (statusCode == 401) {
        _handleUnauthorized();
      }
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

  void _handleUnauthorized() {
    if (_isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;
    unawaited(_storage.logout());

    Future<void>.microtask(() async {
      try {
        final currentRoute = Get.currentRoute;
        final isAuthRoute = currentRoute == Routes.LOGIN ||
            currentRoute == Routes.REGISTER ||
            currentRoute == Routes.FORGOT_PASSWORD ||
            currentRoute == Routes.FORGOT_PASSWORD_RESET ||
            currentRoute == Routes.ONBOARDING ||
            currentRoute == Routes.SPLASH;

        if (!isAuthRoute) {
          await Get.offAllNamed<void>(Routes.LOGIN);
          AppHelpers.showInfoSnackbar(
            message: 'Please sign in again to continue.',
            title: 'Session expired',
          );
        }
      } finally {
        _isHandlingUnauthorized = false;
      }
    });
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
