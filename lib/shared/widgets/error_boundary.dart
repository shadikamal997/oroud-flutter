import 'package:flutter/material.dart';

/// A simple error boundary widget that catches and displays errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? errorWidget;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidget,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorWidget ??
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
    }

    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (error, stackTrace) {
          _error = error;
          widget.onError?.call(error, stackTrace);
          return build(context);
        }
      },
    );
  }
}

/// A loading overlay widget that can be shown on top of content
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingText != null) ...[
                        const SizedBox(height: 16),
                        Text(loadingText!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension to add error handling to async operations
extension AsyncErrorHandler<T> on Future<T> {
  Future<T> catchErrorAndShowSnackBar(BuildContext context, [String? message]) {
    return catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'An error occurred: $error'),
          backgroundColor: Colors.red,
        ),
      );
      throw error;
    });
  }
}