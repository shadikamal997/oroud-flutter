import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  
  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Full screen loading
class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LoadingIndicator(size: 40),
      ),
    );
  }
}
