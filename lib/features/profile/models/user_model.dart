class User {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? name;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? coverUrl;
  final String? shopId;
  final String? shopName;
  final bool? isVerified;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
    this.name,
    this.phoneNumber,
    this.avatarUrl,
    this.coverUrl,
    this.shopId,
    this.shopName,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        name: json['name'] as String?,
        phoneNumber: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        coverUrl: json['coverUrl'] as String?,
        shopId: json['shopId'] as String?,
        shopName: json['shopName'] as String?,
        isVerified: json['isVerified'] as bool?,
      );
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error parsing User from JSON: $e');
      // ignore: avoid_print
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'shopId': shopId,
      'shopName': shopName,
      'isVerified': isVerified,
    };
  }
}
