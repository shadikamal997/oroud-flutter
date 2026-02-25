import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/user_profile_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    
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
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 8),
                        _buildForgotPassword(),
                        const SizedBox(height: 32),
                        _buildSignInButton(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSocialLoginButtons(),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
                        const SizedBox(height: 24),
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
          ClipRect(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.3),
                BlendMode.darken,
              ),
              child: Image.asset(
                "assets/images/signinhero.webp",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2E3431),
                          const Color(0xFF2E3431).withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFFF5F2EE).withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.storefront_rounded,
                    size: 60,
                    color: Color(0xFFB86E45),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2A2A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your shop and offers',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'your.email@example.com',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
          ),
          hintStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.3),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFB86E45),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Color(0xFFB86E45),
          ),
        ),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          labelStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
          ),
          hintStyle: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.3),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFB86E45),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFFB86E45),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFFB86E45),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.go('/password-reset/request'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Color(0xFFB86E45),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB86E45).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading || !_isFormValid() ? null : _handleLogin,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/register'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFFB86E45),
              fontSize: 15,
              fontWeight: FontWeight.bold,
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

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // Google Sign-In Button
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
              onTap: isLoading ? null : _handleGoogleSignIn,
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
                    'Continue with Google',
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
        // Apple Sign-In Button (iOS only, but show on all platforms)
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
              onTap: isLoading ? null : _handleAppleSignIn,
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
                    'Continue with Apple',
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB86E45),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError("Email is required");
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showError("Enter a valid email address");
      return;
    }
    if (password.isEmpty) {
      _showError("Password is required");
      return;
    }
    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    setState(() => isLoading = true);

    try {
      await ref.read(authProvider.notifier).login(email, password);
      
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        final userProfile = await ref.read(userProfileProvider.future);
        
        // Redirect SHOP users to shop dashboard
        if (userProfile?.role == 'SHOP') {
          context.go('/shop-dashboard');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError("Invalid email or password");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        final userProfile = await ref.read(userProfileProvider.future);
        
        // Redirect SHOP users to shop dashboard
        if (userProfile?.role == 'SHOP') {
          context.go('/shop-dashboard');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => isLoading = true);

    try {
      await ref.read(authProvider.notifier).signInWithApple();
      
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        final userProfile = await ref.read(userProfileProvider.future);
        
        // Redirect SHOP users to shop dashboard
        if (userProfile?.role == 'SHOP') {
          context.go('/shop-dashboard');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        // Don't show error if user cancelled
        if (!e.toString().contains('cancelled')) {
          _showError(e.toString().replaceAll('Exception: ', ''));
        }
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  bool _isFormValid() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    return email.isNotEmpty && email.contains('@') && email.contains('.') && 
           password.isNotEmpty && password.length >= 6;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
