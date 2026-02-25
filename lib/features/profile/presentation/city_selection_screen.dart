import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/city_provider.dart';
import '../../../shared/services/city_service.dart';
import '../../../shared/models/city_model.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

final citiesListProvider = FutureProvider<List<City>>((ref) async {
  final cityService = ref.read(cityServiceProvider);
  return cityService.getCities();
});

class CitySelectionScreen extends ConsumerWidget {
  const CitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(citiesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        title: const Text("Select City"),
        backgroundColor: const Color(0xFFB86E45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: citiesAsync.when(
        data: (cities) {
          if (cities.isEmpty) {
            return const Center(
              child: Text("No cities available"),
            );
          }
          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                leading: const Icon(
                  Icons.location_city,
                  color: AppColors.primary,
                ),
                title: Text(
                  city.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ref.read(cityProvider.notifier).setCity(city.id);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
        loading: () => Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Failed to load cities",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.invalidate(citiesListProvider);
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
