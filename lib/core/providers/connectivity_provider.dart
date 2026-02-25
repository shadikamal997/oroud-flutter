import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to monitor network connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider to check if device is online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  
  return connectivity.when(
    data: (results) => results.any((result) => 
      result == ConnectivityResult.mobile || result == ConnectivityResult.wifi),
    loading: () => true, // Assume online while checking
    error: (_, __) => false,
  );
});
