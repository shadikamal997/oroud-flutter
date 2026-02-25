import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';

class ActivityItem {
  final String id;
  final String type;
  final String icon;
  final String title;
  final String message;
  final DateTime timestamp;
  final String color;

  ActivityItem({
    required this.id,
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.color,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      color: json['color'] as String,
    );
  }
}

// Activity Provider
final shopActivityProvider = FutureProvider<List<ActivityItem>>((ref) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/shops/me/activity');
    
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ActivityItem.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    // Return empty list on error
    return [];
  }
});
