class UserNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? offerId;
  final bool isRead;
  final DateTime createdAt;

  UserNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.offerId,
    required this.isRead,
    required this.createdAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      offerId: json['offerId'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'offerId': offerId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
