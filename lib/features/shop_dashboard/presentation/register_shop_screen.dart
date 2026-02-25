import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../../../shared/services/area_service.dart';
import '../../../features/profile/presentation/city_selection_screen.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

/// Shop registration screen for users to become shop owners
class RegisterShopScreen extends ConsumerStatefulWidget {
  const RegisterShopScreen({super.key});

  @override
  ConsumerState<RegisterShopScreen> createState() => _RegisterShopScreenState();
}

class _RegisterShopScreenState extends ConsumerState<RegisterShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedCityId;
  String? _selectedAreaId;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location captured successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture your location')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '${Endpoints.shops}/register',
        data: {
          'name': _nameController.text.trim(),
          'cityId': _selectedCityId,
          'areaId': _selectedAreaId,
          'latitude': _latitude,
          'longitude': _longitude,
        },
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shop registered successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // TODO: Update user role in auth state
          // Navigate to shop dashboard
          context.go('/shop');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register shop: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesState = ref.watch(citiesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Your Shop'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            const Icon(
              Icons.store,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Become a Shop Owner',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start posting offers and reach thousands of customers',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Shop Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                hintText: 'e.g., Pizza Palace',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.storefront),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your shop name';
                }
                if (value.length < 3) {
                  return 'Shop name must be at least 3 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 16),
            
            // City Selector
            citiesState.when(
              data: (cities) => DropdownButtonFormField<String>(
                initialValue: _selectedCityId,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: cities.map((city) {
                  return DropdownMenuItem(
                    value: city.id,
                    child: Text(city.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCityId = value;
                    _selectedAreaId = null; // Reset area when city changes
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading cities: $error'),
            ),
            
            const SizedBox(height: 16),
            
            // Area Selector
            if (_selectedCityId != null)
              Consumer(
                builder: (context, ref, child) {
                  final areasState = ref.watch(areasByCityProvider(_selectedCityId!));
                  
                  return areasState.when(
                    data: (areas) => DropdownButtonFormField<String>(
                      initialValue: _selectedAreaId,
                      decoration: const InputDecoration(
                        labelText: 'Area',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.place),
                      ),
                      items: areas.map((area) {
                        return DropdownMenuItem(
                          value: area.id,
                          child: Text(area.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAreaId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an area';
                        }
                        return null;
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text('Error loading areas: $error'),
                  );
                },
              ),
            
            const SizedBox(height: 24),
            
            // Location Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.my_location,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Shop Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_latitude != null && _longitude != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        icon: _isLoadingLocation
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.gps_fixed),
                        label: Text(
                          _latitude == null
                              ? 'Get Current Location'
                              : 'Update Location',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Terms & Conditions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'By registering, you agree to our shop owner terms and conditions',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Register Shop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
