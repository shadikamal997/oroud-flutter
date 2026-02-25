import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../shared/providers/city_provider.dart';
import '../../../shared/models/city_model.dart';
import '../providers/user_profile_provider.dart';
import './city_selection_screen.dart';
import 'widgets/avatar_upload_widget.dart';
import 'widgets/cover_upload_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String? selectedCityId;
  bool isLoading = false;
  bool isSaving = false;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Track changes
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isLoading) {
      final userAsync = ref.watch(userProfileProvider);

      userAsync.whenData((user) {
        if (user != null && _nameController.text.isEmpty) {
          _nameController.text = user.name ?? '';
          _phoneController.text = user.phoneNumber ?? '';
          _emailController.text = user.email ?? '';
          // Get city from cityProvider instead of user model
          selectedCityId = ref.read(cityProvider);
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  void _onFieldChanged() {
    if (!hasUnsavedChanges) {
      setState(() => hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a city'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final api = ref.read(apiClientProvider);

      final updateData = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'cityId': selectedCityId,
      };

      await api.put('/auth/profile', data: updateData);

      // Refresh profile data
      ref.invalidate(userProfileProvider);

      if (mounted) {
        setState(() => hasUnsavedChanges = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesListProvider);
    final userAsync = ref.watch(userProfileProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F2EE),
        appBar: AppBar(
          title: const Text("Edit Profile"),
          backgroundColor: const Color(0xFFB86E45),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (hasUnsavedChanges)
              TextButton(
                onPressed: isSaving ? null : _save,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
          ],
        ),
        body: userAsync.when(
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
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userProfileProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (user) {
            if (user == null) {
              return const Center(
                child: Text("No user data"),
              );
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Cover Photo
                          CoverUploadWidget(
                            currentCoverUrl: user.coverUrl,
                            onCoverUpdated: (newUrl) {
                              ref.invalidate(userProfileProvider);
                              setState(() => hasUnsavedChanges = true);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Avatar
                          Center(
                            child: AvatarUploadWidget(
                              currentAvatarUrl: user.avatarUrl,
                              onAvatarUpdated: (newUrl) {
                                ref.invalidate(userProfileProvider);
                                setState(() => hasUnsavedChanges = true);
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // User Info
                          Text(
                            user.name ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A2A2A),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            user.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Personal Information Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB86E45).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFFB86E45),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A2A2A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name *",
                              hintText: "Enter your full name",
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Color(0xFFB86E45),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFB86E45),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Email Field (Read-only)
                          TextFormField(
                            controller: _emailController,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Phone Field
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              hintText: "Enter your phone number",
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                color: Color(0xFFB86E45),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFB86E45),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                // Basic phone validation
                                final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{7,15}$');
                                if (!phoneRegex.hasMatch(value)) {
                                  return 'Please enter a valid phone number';
                                }
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // City Selection
                          citiesAsync.when(
                            loading: () => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (err, stack) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Failed to load cities: $err',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            data: (cities) {
                              if (cities.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('No cities available'),
                                );
                              }

                              final selectedCity = cities.firstWhere(
                                (city) => city.id == selectedCityId,
                                orElse: () => cities.first,
                              );

                              return InkWell(
                                onTap: () async {
                                  final result = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CitySelectionScreen(),
                                    ),
                                  );

                                  if (result != null && result != selectedCityId) {
                                    setState(() {
                                      selectedCityId = result;
                                      hasUnsavedChanges = true;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_city,
                                        color: Color(0xFFB86E45),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "City",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              selectedCity.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFB86E45)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Color(0xFFB86E45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (isSaving || !hasUnsavedChanges) ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasUnsavedChanges
                                  ? const Color(0xFFB86E45)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: hasUnsavedChanges ? 3 : 0,
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    hasUnsavedChanges ? "Save Changes" : "No Changes",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
