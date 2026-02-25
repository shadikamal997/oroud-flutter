import 'city_model.dart';

class Area {
  final String id;
  final String name;
  final String cityId;
  final City? city;

  Area({
    required this.id,
    required this.name,
    required this.cityId,
    this.city,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    try {
      return Area(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown',
        cityId: json['cityId']?.toString() ?? '',
        city: json['city'] != null 
            ? City.fromJson(json['city'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing Area: $e, json: $json');
      return Area(id: '', name: 'Unknown', cityId: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cityId': cityId,
      if (city != null) 'city': city!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Area && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Area(id: $id, name: $name, cityId: $cityId)';
}
