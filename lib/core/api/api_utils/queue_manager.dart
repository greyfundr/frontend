// lib/core/network/request_queue.dart
import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:dio/dio.dart';

class QueuedRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  QueuedRequest(this.options, this.completer);
}

class RequestQueue {
  final Queue<QueuedRequest> _queue = Queue<QueuedRequest>();
  
  // Check if queue is empty
  bool get isEmpty => _queue.isEmpty;
  
  // Get queue length
  int get length => _queue.length;
  
  // Add a request to the queue
  Future<Response> enqueue(RequestOptions options) {
    log('Queueing request to: ${options.path}');
    final completer = Completer<Response>();
    _queue.add(QueuedRequest(options, completer));
    log('Queue length: ${_queue.length}');
    return completer.future;
  }
  
  // Process all queued requests with a fresh token
  Future<void> processQueue(String token, Dio dio) async {
    log('Processing queue with ${_queue.length} requests');
    
    // Create a copy of the queue to avoid concurrent modification
    final requestsToProcess = List<QueuedRequest>.from(_queue);
    _queue.clear();
    
    // Process each request
    for (final queuedRequest in requestsToProcess) {
      try {
        // Update token in the request
        queuedRequest.options.headers['Authorization'] = 'Bearer $token';
        
        // Execute the request
        final response = await dio.fetch(queuedRequest.options);
        queuedRequest.completer.complete(response);
        log('Successfully processed queued request to: ${queuedRequest.options.path}');
      } catch (error) {
        if (error is DioException) {
          queuedRequest.completer.completeError(error);
        } else {
          queuedRequest.completer.completeError(
            DioException(
              requestOptions: queuedRequest.options,
              error: error.toString(),
            ),
          );
        }
        log('Error processing queued request: $error');
      }
    }
    
    log('Queue processing completed');
  }
  
  // Fail all queued requests with an error
  void failAllRequests(DioException error) {
    log('Failing all ${_queue.length} queued requests');
    
    final requestsToFail = List<QueuedRequest>.from(_queue);
    _queue.clear();
    
    for (final queuedRequest in requestsToFail) {
      queuedRequest.completer.completeError(error);
    }
    
    log('All queued requests failed');
  }
}