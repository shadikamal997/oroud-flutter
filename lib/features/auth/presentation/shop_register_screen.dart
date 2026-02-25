import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';
import '../../../shared/models/city_model.dart';
import '../../../shared/models/area_model.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/config/app_config.dart';

class ShopRegisterScreen extends ConsumerStatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  ConsumerState<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends ConsumerState<ShopRegisterScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Shop location fields
  List<City> _cities = [];
  List<Area> _areas = [];
  City? _selectedCity;
  Area? _selectedArea;
  bool _loadingCities = false;
  bool _loadingAreas = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
    _shopNameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    if (!mounted) return;
    setState(() => _loadingCities = true);
    try {
      final api = ref.read(apiClientProvider);
      debugPrint("🔵 Fetching cities from: ${AppConfig.baseUrl}${Endpoints.cities}");
      final response = await api.get(Endpoints.cities);
      debugPrint("🔵 Cities response received");
      debugPrint("🔵 Response type: ${response.data.runtimeType}");
      debugPrint("🔵 Response data: ${response.data}");
      
      if (response.data is! List) {
        throw Exception('Expected List but got ${response.data.runtimeType}');
      }
      
      final List<City> parsedCities = [];
      for (var item in response.data as List) {
        try {
          final city = City.fromJson(item as Map<String, dynamic>);
          if (city.id.isNotEmpty) {
            parsedCities.add(city);
          }
        } catch (e) {
          debugPrint("⚠️ Skipping city due to parse error: $e");
        }
      }
      
      if (!mounted) return;
      setState(() {
        _cities = parsedCities;
      });
      debugPrint("✅ Loaded ${_cities.length} cities");
    } catch (e, stack) {
      debugPrint("❌ Error loading cities: $e");
      debugPrint("❌ Stack trace: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: Cannot reach server'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  Future<void> _fetchAreas(String cityId) async {
    if (!mounted) return;
    setState(() {
      _loadingAreas = true;
      _areas = [];
      _selectedArea = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      debugPrint("🔵 Fetching areas for city: $cityId");
      final response = await api.get(Endpoints.areas, query: {'cityId': cityId});
      debugPrint("🔵 Areas response received");
      
      if (response.data is! List) {
        throw Exception('Expected List but got ${response.data.runtimeType}');
      }
      
      final List<Area> parsedAreas = [];
      for (var item in response.data as List) {
        try {
          final area = Area.fromJson(item as Map<String, dynamic>);
          if (area.id.isNotEmpty) {
            parsedAreas.add(area);
          }
        } catch (e) {
          debugPrint("⚠️ Skipping area due to parse error: $e");
        }
      }
      
      if (!mounted) return;
      setState(() {
        _areas = parsedAreas;
      });
      debugPrint("✅ Loaded ${_areas.length} areas for city $cityId");
    } catch (e, stack) {
      debugPrint("❌ Error loading areas: $e");
      debugPrint("❌ Stack trace: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: Cannot reach server'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingAreas = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _shopNameController.text.trim().isNotEmpty &&
           _emailController.text.trim().isNotEmpty &&
           _phoneController.text.trim().isNotEmpty &&
           _passwordController.text.length >= 6 &&
           _passwordController.text == _confirmPasswordController.text &&
           _selectedCity != null &&
           _selectedArea != null;
  }

  Future<void> _handleRegister() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all required fields"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.registerShop(
        shopName: _shopNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        cityId: _selectedCity!.id,
        areaId: _selectedArea!.id,
        latitude: 31.9454, // Default Amman coordinates
        longitude: 35.9284,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Shop registered successfully! 🎉 Welcome!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Redirect to shop dashboard after shop registration
        context.go('/shop-dashboard');
      }
    } catch (e) {
      if (mounted) {
        // Extract clean error message
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        
        if (e is DioException) {
          if (e.response != null && e.response!.data != null) {
            try {
              final responseData = e.response!.data;
              
              if (responseData is Map && responseData.containsKey('message')) {
                final message = responseData['message'] as String;
                
                if (message.contains('Phone number already registered')) {
                  errorMessage = "This phone number is already registered.\nPlease sign in or use a different number.";
                } else if (message.contains('Email already registered')) {
                  errorMessage = "This email is already registered.\nPlease sign in or use a different email.";
                } else if (message.contains('phone') && message.contains('already')) {
                  errorMessage = "This phone number is already in use.\nPlease use a different number.";
                } else if (message.contains('email') && message.contains('already')) {
                  errorMessage = "This email is already in use.\nPlease use a different email.";
                } else {
                  errorMessage = message;
                }
              }
            } catch (_) {}
          } else if (e.response?.statusCode == 409) {
            errorMessage = "Email or phone already registered.\nPlease use different credentials or sign in.";
          } else if (e.response?.statusCode == 400) {
            errorMessage = "Invalid information.\nPlease check all fields.";
          } else if (e.type == DioExceptionType.connectionTimeout ||
                     e.type == DioExceptionType.receiveTimeout) {
            errorMessage = "Connection timeout.\nPlease check your internet connection.";
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = "Cannot connect to server.\nPlease check your internet connection.";
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Registration Failed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(errorMessage),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        _buildTitleSection(),
                        const SizedBox(height: 32),
                        _buildShopNameField(),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPhoneField(),
                        const SizedBox(height: 16),
                        _buildCityDropdown(),
                        const SizedBox(height: 16),
                        _buildAreaDropdown(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 16),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 24),
                        _buildRegisterButton(),
                        const SizedBox(height: 24),
                        _buildSignInLink(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3431),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2E3431).withValues(alpha: 0.95),
                  const Color(0xFF2E3431),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'OROUD',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3431),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Shop Account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A2A2A),
            height: 1.2,
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join Oroud and reach thousands of customers',
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildShopNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _shopNameController,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Shop Name *',
          hintText: 'Enter your shop name',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.store_outlined,
            color: Color(0xFFB86E45),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Email Address *',
          hintText: 'shop@example.com',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Color(0xFFB86E45),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Phone Number *',
          hintText: '07xxxxxxxx',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.phone_outlined,
            color: Color(0xFFB86E45),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<City>(
      initialValue: _selectedCity,
      decoration: InputDecoration(
        labelText: 'City *',
        labelStyle: TextStyle(
          color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(
          Icons.location_city,
          color: Color(0xFFB86E45),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB86E45), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      hint: _loadingCities 
        ? const Text("Loading cities...")
        : const Text("Select city"),
      items: _cities.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city.name),
        );
      }).toList(),
      onChanged: _loadingCities
          ? null
          : (City? city) {
              setState(() {
                _selectedCity = city;
                _selectedArea = null;
                _areas = [];
              });
              if (city != null) {
                _fetchAreas(city.id);
              }
            },
    );
  }

  Widget _buildAreaDropdown() {
    return DropdownButtonFormField<Area>(
      initialValue: _selectedArea,
      decoration: InputDecoration(
        labelText: 'Area *',
        labelStyle: TextStyle(
          color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(
          Icons.location_on,
          color: Color(0xFFB86E45),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB86E45), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      hint: _selectedCity == null
          ? const Text("Select city first")
          : _loadingAreas
              ? const Text("Loading areas...")
              : const Text("Select area"),
      items: _areas.map((area) {
        return DropdownMenuItem(
          value: area,
          child: Text(area.name),
        );
      }).toList(),
      onChanged: _selectedCity == null || _loadingAreas
          ? null
          : (Area? area) {
              setState(() {
                _selectedArea = area;
              });
            },
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Password *',
          hintText: 'At least 6 characters',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFFB86E45),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: const Color(0xFFB86E45),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Confirm Password *',
          hintText: 'Re-enter password',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFFB86E45),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: const Color(0xFFB86E45),
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    final isFormValid = _isFormValid();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isFormValid
            ? const LinearGradient(
                colors: [
                  Color(0xFFB86E45),
                  Color(0xFFCC7F54),
                ],
              )
            : null,
        color: isFormValid ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isFormValid
            ? [
                BoxShadow(
                  color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isFormValid && !isLoading ? _handleRegister : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Register Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have a shop account? ',
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
          ),
        ),
        GestureDetector(
          onTap: () {
            context.go('/login');
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFFB86E45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
