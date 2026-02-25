import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Location provider that handles permission request and position retrieval
/// Returns null if:
/// - Location services are disabled
/// - Permission is denied
/// - Permission is permanently denied
/// 
/// This ensures clean UX with no forced permission dialogs
final locationProvider = FutureProvider<Position?>((ref) async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  // Check current permission status
  LocationPermission permission = await Geolocator.checkPermission();

  // Request permission if denied (first time)
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }

  // Handle permanently denied
  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  // Get current position
  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
});
