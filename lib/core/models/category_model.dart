class Category {
  final String id;
  final String name;
  final String? icon;
  final bool isActive;
  final DateTime createdAt;
  final List<Subcategory> subcategories;

  Category({
    required this.id,
    required this.name,
    this.icon,
    required this.isActive,
    required this.createdAt,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => Subcategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }
}

class Subcategory {
  final String id;
  final String name;
  final String categoryId;
  final bool isActive;
  final DateTime createdAt;

  Subcategory({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.isActive,
    required this.createdAt,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
