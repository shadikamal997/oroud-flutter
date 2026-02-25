import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/user_profile_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
    
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';
    if (password.length < 8) return 'Fair';
    if (password.length >= 8 && RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[0-9]').hasMatch(password)) {
      return 'Strong';
    }
    return 'Good';
  }

  Color _getPasswordStrengthColor() {
    final strength = _getPasswordStrength();
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Fair':
        return Colors.orange;
      case 'Good':
        return const Color(0xFFB86E45);
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getPasswordStrengthProgress() {
    final strength = _getPasswordStrength();
    switch (strength) {
      case 'Weak':
        return 0.25;
      case 'Fair':
        return 0.5;
      case 'Good':
        return 0.75;
      case 'Strong':
        return 1.0;
      default:
        return 0.0;
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          _buildTitleSection(),
                          const SizedBox(height: 32),
                          _buildNameField(),
                          const SizedBox(height: 16),
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPhoneField(),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildPasswordStrengthIndicator(),
                          ],
                          const SizedBox(height: 16),
                          _buildConfirmPasswordField(),
                          const SizedBox(height: 24),
                          _buildTermsCheckbox(),
                          const SizedBox(height: 24),
                          _buildSignUpButton(),
                          const SizedBox(height: 24),
                          _buildDivider(),
                          const SizedBox(height: 24),
                          _buildSocialSignUpButtons(),
                          const SizedBox(height: 24),
                          _buildSignInLink(),
                          const SizedBox(height: 32),
                        ],
                      ),
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
          // Blurred background effect (optional)
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
          // Circular logo
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
          'Create an Account',
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
          'Join Oroud and start discovering local offers',
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
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
      child: TextFormField(
        controller: _nameController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Full Name',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.person_outline,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
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
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Email Address',
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
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
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Phone Number',
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          }
          return null;
        },
      ),
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
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Password',
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final strength = _getPasswordStrength();
    if (strength.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _getPasswordStrengthProgress(),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getPasswordStrengthColor()),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getPasswordStrengthColor(),
              ),
            ),
          ],
        ),
      ],
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
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Confirm Password',
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          }
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFFB86E45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptedTerms = !_acceptedTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF2A2A2A).withValues(alpha: 0.7),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'By creating an account, you agree to our '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: const TextStyle(
                      color: Color(0xFFB86E45),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    final isFormValid = _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _acceptedTerms;

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
          onTap: isFormValid && !isLoading ? _handleSignUp : null,
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
                    'Join the Community',
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
          'Already have an account? ',
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSignUpButtons() {
    return Column(
      children: [
        // Google Sign-Up Button
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF2A2A2A).withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _handleGoogleSignUp,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/google.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Color(0xFFDB4437),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign up with Google',
                    style: TextStyle(
                      color: const Color(0xFF2A2A2A).withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Apple Sign-Up Button
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _handleAppleSignUp,
              borderRadius: BorderRadius.circular(18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Sign up with Apple',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Register as USER role (explicitly)
      await ref.read(authProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: 'USER', // Explicitly set USER role
          );

      if (mounted) {
        // Show success animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Account created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Wait a moment for profile to load, then navigate to home
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        
        // Extract clean error message
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        
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
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => isLoading = true);

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Account created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          final userProfile = await ref.read(userProfileProvider.future);
          
          // Redirect based on user role
          if (userProfile?.role == 'SHOP') {
            context.go('/shop-dashboard');
          } else {
            context.go('/');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleAppleSignUp() async {
    setState(() => isLoading = true);

    try {
      await ref.read(authProvider.notifier).signInWithApple();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Account created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          final userProfile = await ref.read(userProfileProvider.future);
          
          // Redirect based on user role
          if (userProfile?.role == 'SHOP') {
            context.go('/shop-dashboard');
          } else {
            context.go('/');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        
        // Don't show error if user cancelled
        if (!e.toString().contains('cancelled')) {
          String errorMessage = e.toString().replaceFirst('Exception: ', '');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }
}
