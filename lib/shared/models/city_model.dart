class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    try {
      return City(
        id: json["id"]?.toString() ?? '',
        name: json["name"]?.toString() ?? 'Unknown',
      );
    } catch (e) {
      print('Error parsing City: $e, json: $json');
      return City(id: '', name: 'Unknown');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }

  // ✅ FIX: Add equality operators for Flutter dropdown
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
