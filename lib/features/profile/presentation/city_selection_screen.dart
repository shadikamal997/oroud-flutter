import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/city_provider.dart';

class CitySelectionScreen extends ConsumerWidget {
  const CitySelectionScreen({super.key});

  final cities = const [
    {"id": "1", "name": "Amman"},
    {"id": "2", "name": "Irbid"},
    {"id": "3", "name": "Zarqa"},
    {"id": "4", "name": "Aqaba"},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select City")),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          return ListTile(
            title: Text(city["name"]!),
            onTap: () {
              ref.read(cityProvider.notifier).setCity(city["id"]!);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
