// lib/core/network/api_client.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greyfundr/core/api/api_utils/network_exception.dart';
import 'package:greyfundr/core/api/api_utils/queue_manager.dart';
import 'package:greyfundr/core/api/api_utils/response_handler.dart';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';
import 'token_manager.dart';
import 'error_handler.dart';

class ApiClient {
  final Dio _dio;
  final TokenManager _tokenManager;
  final RequestQueue _requestQueue;
  final ErrorHandler _errorHandler;
  bool _isRefreshing = false;

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal()
    : _dio = Dio(),
      _tokenManager = TokenManager(),
      _requestQueue = RequestQueue(),
      _errorHandler = ErrorHandler() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresToken = options.headers.remove('requiresToken');

          if (requiresToken == 'true' || requiresToken == null) {
            final token = await _tokenManager.getAccessToken();
            options.headers['Authorization'] = 'Bearer $token';
          }
          

          log('🚀 REQUEST DETAILS:', name: 'API');
          log('URL INTERCEPTOR: ${options.uri}', name: 'API');
          log('HEADERS INTERCEPTOR: ${options.headers}', name: 'API');
          log('DATA INTERCEPTOR: ${options.data}', name: 'API');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response details
          log('✅ RESPONSE DETAILS:', name: 'API');
          log('STATUS CODE: ${response.statusCode}', name: 'API');
          log('DATA: ${jsonEncode(response.data)}', name: 'API');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Log error details
          
          log('❌ ERROR DETAILS: $error', name: 'API');

          // Handle token refresh for 401 errors
          if (error.response?.statusCode == 401) {
            log("401 DETECTED ::: CALLING TOKEN REFRESH");
            if (_isRefreshing) {
              // If already refreshing, queue this request
              final retryRequest = _storeRequest(error.requestOptions);
              return handler.resolve(await retryRequest);
            } else {
              // Start token refresh process
              _isRefreshing = true;
              try {
                String newAccessToken = await _tokenManager.refreshToken();
                // Retry all queued requests with new token
                final retryResponse = await _retryRequest(
                  error.requestOptions,
                  newAccessToken,
                );
                await _processQueue();
                return handler.resolve(retryResponse);
              } on NetworkException catch (e) {
                // If refresh fails, fail all queued requests
                _requestQueue.failAllRequests(
                  DioException(
                    requestOptions: error.requestOptions,
                    error:
                        "Please check your internet connection and try again.",
                  ),
                );
                Sentry.captureException(error, stackTrace: error.stackTrace);
                return handler.reject(error);
              } catch (e) {
                // If refresh fails, fail all queued requests
                _requestQueue.failAllRequests(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: "Authentication failed: $e",
                  ),
                );
                Sentry.captureException(error, stackTrace: error.stackTrace);
                return handler.reject(error);
              } finally {
                _isRefreshing = false;
              }
            }
          }
          // For other errors, pass to error handler
          return _errorHandler.handleError(error, handler);
        },
      ),
    );
  }

  Future<Response> _storeRequest(RequestOptions options) {
    return _requestQueue.enqueue(options);
  }

  Future<Response> _retryRequest(
    RequestOptions options,
    String newAccessToken,
  ) async {
    // Update the token in request before retrying
    // final token = await _tokenManager.getAccessToken();
    options.headers['Authorization'] = 'Bearer $newAccessToken';

    return _dio.fetch(options);
  }

  Future<void> _processQueue() async {
    if (_requestQueue.isEmpty) return;

    final token = await _tokenManager.getAccessToken();
    await _requestQueue.processQueue(token, _dio);
  }

  // Helper to set common options
  Options _getOptions(
    Map<String, dynamic>? headers, {
    bool requiresToken = true,
  }) {
    final optionHeaders = headers ?? <String, dynamic>{};

    if (requiresToken) {
      optionHeaders['requiresToken'] = 'true';
    } else {
      optionHeaders['requiresToken'] = 'false';
    }
    return Options(
      headers: optionHeaders,
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  // API methods
  Future<String> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresToken = true,
    bool hideLog = true,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: _getOptions(headers, requiresToken: requiresToken)
          ..responseType = ResponseType.plain,
      );
      if (!hideLog) {
        log('🚀 GET REQUEST:', name: 'API');
        log('URL: $url', name: 'API');
        log('QUERY PARAMETERS: $queryParameters', name: 'API');
        log('HEADERS: $headers', name: 'API');
        log('✅ GET Response: ${response.data}', name: 'API');
      }
      return response.toString();
    } on DioException catch (e) {
      log("DioException occurred");
      final response = await responseHandler(
        e.response ??
            Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
              statusMessage: "Error",
            ),
      );
      if (!hideLog) log(response.toString());
      return response.toString();
    } catch (e) {
      throw "An error occurred";
    }
  }

  Future<String> post(
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    FormData? formData,
    bool requiresToken = true,
    bool requiresIdempotency = true,
    bool hideLog = true,
    CancelToken? cancelToken, // <-- added
  }) async {
    if (requiresIdempotency) {
      headers ??= {};
      // headers['idempotencyKey'] = generateIdempotencyKey();
    }
    try {
      final isForm = formData != null || body is FormData;
      final opts = _getOptions(headers, requiresToken: requiresToken);
      // Let Dio set the Content-Type (and boundary) when sending FormData.
      if (!isForm) opts.contentType = 'application/json';
      opts.responseType = ResponseType.plain;
      opts.method = 'POST';

      final response = await _dio.post(
        url,
        data: formData ?? body,
        options: opts,
        cancelToken: cancelToken, // <-- pass through
      );

      if (!hideLog) {
        log('🚀 POST REQUEST:', name: 'API');
        log('URL: $url', name: 'API');
        log('BODY: ${formData ?? body}', name: 'API');
        log('HEADERS: $headers', name: 'API');
        log('✅ POST Response: ${response.data}', name: 'API');
      }
      return response.toString();
    } on DioException catch (e) {
      // propagate cancellation so callers can detect it
      if (e.type == DioExceptionType.cancel) {
        log("Request cancelled", name: 'API');
        rethrow;
      }
      log("DioException occurred");
      final response = await responseHandler(
        e.response ??
            Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
              statusMessage: "Error",
            ),
      );
      if (!hideLog) log(response.toString());
      return response.data.toString();
    } catch (e) {
      throw "An error occurred";
    }
  }

  Future<String> put(
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    FormData? formData,
    bool requiresToken = true,
    bool hideLog = true,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: formData ?? body,
        options: _getOptions(headers, requiresToken: requiresToken),
      );
      if (!hideLog) {
        log('🚀 PUT REQUEST:', name: 'API');
        log('URL: $url', name: 'API');
        log('BODY: ${formData ?? body}', name: 'API');
        log('HEADERS: $headers', name: 'API');
        log('✅ PUT Response: ${response.data}', name: 'API');
      }
      return response.toString();
    } on DioException catch (e) {
      log("DioException occurred");
      final response = await responseHandler(
        e.response ??
            Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
              statusMessage: "Error",
            ),
      );
      if (!hideLog) log(response.toString());
      return response.data.toString();
    } catch (e) {
      throw "An error occurred";
    }
  }

  Future<String> patch(
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    bool requiresToken = true,
    bool hideLog = true,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: body,
        options: _getOptions(headers, requiresToken: requiresToken),
      );
      if (!hideLog) {
        log('🚀 PATCH REQUEST:', name: 'API');
        log('URL: $url', name: 'API');
        log('BODY: $body', name: 'API');
        log('HEADERS: $headers', name: 'API');
        log('✅ PATCH Response: ${response.data}', name: 'API');
      }
      return response.toString();
    } on DioException catch (e) {
      log("DioException occurred");
      final response = await responseHandler(
        e.response ??
            Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
              statusMessage: "Error",
            ),
      );
      if (!hideLog) log(response.toString());
      return response.data.toString();
    } catch (e) {
      throw "An error occurred";
    }
  }

  Future<String> delete(
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    bool requiresToken = true,
    bool hideLog = true,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        data: body,
        options: _getOptions(headers, requiresToken: requiresToken),
      );
      if (!hideLog) {
        log('🚀 DELETE REQUEST:', name: 'API');
        log('URL: $url', name: 'API');
        log('BODY: $body', name: 'API');
        log('HEADERS: $headers', name: 'API');
        log('✅ DELETE Response: ${response.data}', name: 'API');
      }
      return response.toString();
    } on DioException catch (e) {
      log("DioException occurred");
      final response = await responseHandler(
        e.response ??
            Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
              statusMessage: "Error",
            ),
      );
      if (!hideLog) log(response.toString());
      return response.data.toString();
    } catch (e) {
      throw "An error occurred";
    }
  }
}
