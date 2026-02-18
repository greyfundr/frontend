// lib/core/network/error_handler.dart
import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';

enum ErrorType {
  network,
  timeout,
  unauthorized,
  badRequest,
  notFound,
  server,
  unknown
}

class ApiError {
  final ErrorType type;
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'message': message,
      'statusCode': statusCode,
      'data': data,
    };
  }

  @override
  String toString() {
    return '{"error": true, "type": "${type.name}", "message": "$message", "statusCode": $statusCode, "data": $data}';
  }
}

class ErrorHandler {
  void handleError(DioException error, ErrorInterceptorHandler handler) {
    // Determine if this error should be retried
    if (_shouldRetry(error)) {
      _retryRequest(error, handler);
    } else {
      handler.next(error);
    }
  }

  bool _shouldRetry(DioException error) {
    // Retry network errors or timeouts up to a limit
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.error is SocketException)) {
      // Get current retry count from error context
      final retryCount = error.requestOptions.extra['retryCount'] as int? ?? 0;
      return retryCount < 2; // Maximum 2 retries (3 attempts total)
    }

    return false;
  }

  Future<void> _retryRequest(
      DioException error, ErrorInterceptorHandler handler) async {
    final options = error.requestOptions;

    // Increment retry count
    final retryCount = (options.extra['retryCount'] as int? ?? 0) + 1;
    options.extra['retryCount'] = retryCount;

    log('Retrying request (attempt $retryCount): ${options.path}');

    try {
      // Add exponential backoff delay
      final delay = Duration(milliseconds: 300 * (1 << retryCount));
      await Future.delayed(delay);

      // Create a new request with the same options
      final dio = Dio();
      final response = await dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      log('Retry attempt $retryCount failed: $e');
      handler.next(error);
    }
  }

  // void formatError(dynamic error) {
  //   ApiError apiError;

  //   if (error is DioException) {
  //     // Handle Dio errors
  //     switch (error.type) {
  //       case DioExceptionType.connectionTimeout:
  //       case DioExceptionType.sendTimeout:
  //       case DioExceptionType.receiveTimeout:
  //         apiError = ApiError(
  //           type: ErrorType.timeout,
  //           message: 'Request timed out',
  //           statusCode: 408,
  //         );
  //         break;

  //       case DioExceptionType.badResponse:
  //         final statusCode = error.response?.statusCode;
  //         switch (statusCode) {
  //           case 400:
  //             apiError = ApiError(
  //               type: ErrorType.badRequest,
  //               message: 'Bad request',
  //               statusCode: statusCode,
  //               data: error.response?.data,
  //             );
  //             break;
  //           case 401:
  //             apiError = ApiError(
  //               type: ErrorType.unauthorized,
  //               message: 'Unauthorized',
  //               statusCode: statusCode,
  //               data: error.response?.data,
  //             );
  //             break;
  //           case 404:
  //             apiError = ApiError(
  //               type: ErrorType.notFound,
  //               message: 'Resource not found',
  //               statusCode: statusCode,
  //               data: error.response?.data,
  //             );
  //             break;
  //           case 500:
  //           case 501:
  //           case 502:
  //           case 503:
  //             apiError = ApiError(
  //               type: ErrorType.server,
  //               message: 'Server error',
  //               statusCode: statusCode,
  //               data: error.response?.data,
  //             );
  //             break;
  //           default:
  //             apiError = ApiError(
  //               type: ErrorType.unknown,
  //               message: 'Unknown error occurred',
  //               statusCode: statusCode,
  //               data: error.response?.data,
  //             );
  //         }
  //         break;

  //       case DioExceptionType.cancel:
  //         apiError = ApiError(
  //           type: ErrorType.unknown,
  //           message: 'Request was cancelled',
  //         );
  //         break;

  //       default:
  //         if (error.error is SocketException) {
  //           apiError = ApiError(
  //             type: ErrorType.network,
  //             message: 'Network error, please check your connection',
  //           );
  //         } else {
  //           apiError = ApiError(
  //             type: ErrorType.unknown,
  //             message: error.message ?? 'An unexpected error occurred',
  //             data: error.error.toString(),
  //           );
  //         }
  //     }
  //   } else {
  //     // Handle non-Dio errors
  //     apiError = ApiError(
  //       type: ErrorType.unknown,
  //       message: error.toString(),
  //     );
  //   }

  //   log('Formatted error: ${apiError.toString()}');
  //   return "${apiError.toString()}";
  // }

}
