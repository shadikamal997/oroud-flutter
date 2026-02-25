import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Simple performance chart widget for offer analytics
class PerformanceChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final Color color;
  final String valueLabel;

  const PerformanceChart({
    super.key,
    required this.data,
    required this.title,
    required this.color,
    required this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final maxValue = data.map((e) => e.value).reduce(math.max);
    final minValue = data.map((e) => e.value).reduce(math.min);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    valueLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: _ChartPainter(
                  data: data,
                  color: color,
                  maxValue: maxValue,
                  minValue: minValue,
                ),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('Min', minValue.toString(), Colors.grey),
                _buildMetric('Max', maxValue.toString(), color),
                _buildMetric(
                  'Avg',
                  (data.map((e) => e.value).reduce((a, b) => a + b) /
                          data.length)
                      .toStringAsFixed(1),
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});
}

class _ChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color color;
  final double maxValue;
  final double minValue;

  _ChartPainter({
    required this.data,
    required this.color,
    required this.maxValue,
    required this.minValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final spacing = size.width / (data.length - 1);
    final range = maxValue - minValue;
    final normalizedRange = range == 0 ? 1 : range;

    // Draw area
    final path = Path();
    path.moveTo(0, size.height);

    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final normalizedValue = (data[i].value - minValue) / normalizedRange;
      final y = size.height - (normalizedValue * size.height);
      if (i == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Draw line
    final linePath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final normalizedValue = (data[i].value - minValue) / normalizedRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final normalizedValue = (data[i].value - minValue) / normalizedRange;
      final y = size.height - (normalizedValue * size.height);

      // Outer circle
      canvas.drawCircle(Offset(x, y), 6, dotPaint);
      // Inner circle
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.minValue != minValue;
  }
}
