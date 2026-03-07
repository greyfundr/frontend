import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(dynamic error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();
}

class ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  Function(FlutterErrorDetails)? _previousHandler;

  @override
  void initState() {
    super.initState();

    // Save existing Flutter error handler
    _previousHandler = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // Call original handler first (important!)
      _previousHandler?.call(details);

      if (!mounted) return;

      setState(() {
        _hasError = true;
        _error = details.exception;
        _stackTrace = details.stack ?? StackTrace.current;
      });

      widget.onError?.call(_error!, _stackTrace!);
    };
  }

  @override
  void dispose() {
    // Restore original error handler
    FlutterError.onError = _previousHandler;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Fallback UI
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
