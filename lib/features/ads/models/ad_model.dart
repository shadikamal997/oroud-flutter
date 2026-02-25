class Ad {
  final String id;
  final String title;
  final String imageUrl;
  final String redirectUrl;
  final int priority;
  final int clicks;

  Ad({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.redirectUrl,
    required this.priority,
    required this.clicks,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      redirectUrl: json['redirectUrl'],
      priority: json['priority'] ?? 0,
      clicks: json['clicks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'redirectUrl': redirectUrl,
      'priority': priority,
      'clicks': clicks,
    };
  }
}
