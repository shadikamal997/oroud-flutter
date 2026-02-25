class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final List<SubcategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => SubcategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (icon != null) 'icon': icon,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }
}

class SubcategoryModel {
  final String id;
  final String name;

  SubcategoryModel({
    required this.id,
    required this.name,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
