import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/unread_notification_count_provider.dart';
import '../models/user_model.dart';
import 'guest_profile_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'widgets/cover_upload_widget.dart';
import 'widgets/avatar_upload_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    // Show Guest Profile for non-logged-in users
    if (!isLoggedIn) {
      return const GuestProfileScreen();
    }

    final userAsync = ref.watch(userProfileProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

    return userAsync.when(
      data: (user) {
        print("📊 PROFILE DATA STATE: $user");
        print("📊 User role: ${user?.role}");
        print("📊 User email: ${user?.email}");
        print("📊 User name: ${user?.name}");

        if (user == null) {
          print("⚠️ USER IS NULL → showing guest");
          return const GuestProfileScreen();
        }

        print("✅ USER LOADED → building profile for ${user.email}");
        
        return Scaffold(
          backgroundColor: const Color(0xFFF5F2EE),
          body: SafeArea(
            child: Column(
              children: [
                // Custom Header
                _buildCustomHeader(context, user),
                
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _ProfileHeader(
                          user: user,
                          onProfileUpdate: () {
                            ref.invalidate(userProfileProvider);
                          },
                        ),
                        _ProfileInfo(user: user),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A2A2A),
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 16),
                              _QuickActions(unreadCount: unreadCountAsync.value ?? 0),
                              const SizedBox(height: 32),
                              const Text(
                                'Account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A2A2A),
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 16),
                              const _SettingsSection(),
                              const SizedBox(height: 24),
                              _LogoutButton(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        print("⏳ PROFILE LOADING");
        return Scaffold(
          backgroundColor: const Color(0xFFF5F2EE),
          body: Center(
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
        );
      },
      error: (e, _) {
        print("❌ PROFILE ERROR: $e");
        return Scaffold(
          backgroundColor: const Color(0xFFF5F2EE),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text("Error: $e"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userProfileProvider),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCustomHeader(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'My Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2A2A),
                fontFamily: 'serif',
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                size: 20,
                color: Color(0xFFB86E45),
              ),
              onPressed: () => context.push('/edit-profile'),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final User user;
  final VoidCallback onProfileUpdate;

  const _ProfileHeader({
    required this.user,
    required this.onProfileUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image with Upload Widget
        Stack(
          children: [
            // Cover Image Display
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                image: user.coverUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              // Gradient overlay if there's a cover image
              child: user.coverUrl != null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                    )
                  : null,
            ),
            // Mini Cover Upload Widget (just the button)
            Positioned(
              bottom: 12,
              right: 12,
              child: _CoverUploadButton(
                currentCoverUrl: user.coverUrl,
                onCoverUpdated: (url) => onProfileUpdate(),
              ),
            ),
          ],
        ),

        // Avatar positioned at bottom center with upload capability
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Center(
            child: _AvatarUploadButton(
              currentAvatarUrl: user.avatarUrl,
              userEmail: user.email,
              onAvatarUpdated: (url) => onProfileUpdate(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final User user;

  const _ProfileInfo({required this.user});

  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print user data
    print('🔍 _ProfileInfo building with user data:');
    print('   Name: ${user.name}');
    print('   Email: ${user.email}');
    print('   Role: "${user.role}"');
    print('   Role uppercase: "${user.role.toUpperCase()}"');
    print('   Is SHOP? ${user.role == 'SHOP'}');
    print('   Is SHOP (uppercase)? ${user.role.toUpperCase() == 'SHOP'}');
    print('   Phone: ${user.phoneNumber}');
    print('   Shop Name: ${user.shopName}');
    print('   Is Verified: ${user.isVerified}');
    print('   Created At: ${user.createdAt}');
    
    // Determine role - use uppercase for comparison
    final isShop = user.role.toUpperCase() == 'SHOP';
    final roleDisplay = isShop ? 'Shop Owner' : 'Customer';
    final roleColor = isShop ? const Color(0xFFB86E45) : Colors.blue;
    final roleIcon = isShop ? Icons.store : Icons.person;
    
    print('   >>> Final decision: isShop=$isShop, display="$roleDisplay"');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 70), // Space for avatar
          
          // DEBUG: Red border container to make sure it's visible
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Name - Make it VERY visible
                Text(
                  user.name ?? user.email.split('@')[0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        roleIcon,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        roleDisplay,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Email
                _InfoRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: user.email,
                ),
                
                // Phone
                if (user.phoneNumber != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: user.phoneNumber!,
                  ),
                ],
                
                // Shop Info (for shop owners)
                if (isShop && user.shopName != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.storefront,
                    label: 'Shop',
                    value: user.shopName!,
                    trailing: user.isVerified == true
                        ? const Icon(Icons.verified, size: 16, color: Color(0xFFB86E45))
                        : null,
                  ),
                ],
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                
                // Member Since
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Member since ${_formatMemberSince(user.createdAt)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for info rows
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFB86E45)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final int unreadCount;
  
  const _QuickActions({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _ActionCard(
          icon: Icons.favorite,
          label: "Saved",
          count: null,
          onTap: () => context.push('/saved-offers'),
        ),
        _ActionCard(
          icon: Icons.confirmation_number,
          label: "Claims",
          count: null,
          onTap: () => context.push('/my-claims'),
        ),
        _ActionCard(
          icon: Icons.store,
          label: "Following",
          count: null,
          onTap: () => context.push('/following'),
        ),
        _ActionCard(
          icon: Icons.notifications,
          label: "Notifications",
          count: unreadCount > 0 ? unreadCount : null,
          onTap: () => context.push('/notifications'),
        ),
        _ActionCard(
          icon: Icons.star,
          label: "Reviews",
          count: null,
          onTap: () => context.push('/my-reviews'),
        ),
        _ActionCard(
          icon: Icons.settings,
          label: "Settings",
          count: null,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFB86E45).withValues(alpha: 0.15),
                            const Color(0xFFCC7F54).withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 24, color: const Color(0xFFB86E45)),
                    ),
                    if (count != null && count! > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            count! > 99 ? '99+' : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A2A2A),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB86E45).withValues(alpha: 0.15),
                    const Color(0xFFCC7F54).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFFB86E45),
                size: 22,
              ),
            ),
            title: const Text(
              "Change City",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A2A2A),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => context.push('/select-city'),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB86E45).withValues(alpha: 0.15),
                    const Color(0xFFCC7F54).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Color(0xFFB86E45),
                size: 22,
              ),
            ),
            title: const Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A2A2A),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => context.push('/settings'),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB86E45).withValues(alpha: 0.15),
                    const Color(0xFFCC7F54).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFFB86E45),
                size: 22,
              ),
            ),
            title: const Text(
              "Help & Support",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A2A2A),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => context.push('/help-support'),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB86E45).withValues(alpha: 0.15),
                    const Color(0xFFCC7F54).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: Color(0xFFB86E45),
                size: 22,
              ),
            ),
            title: const Text(
              "Privacy Policy",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A2A2A),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB86E45).withValues(alpha: 0.15),
                    const Color(0xFFCC7F54).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFFB86E45),
                size: 22,
              ),
            ),
            title: const Text(
              "Terms of Service",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A2A2A),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await ref.read(authProvider.notifier).logout();
                        context.go('/');
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red.shade400,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cover Upload Button Widget
class _CoverUploadButton extends ConsumerStatefulWidget {
  final String? currentCoverUrl;
  final Function(String) onCoverUpdated;

  const _CoverUploadButton({
    this.currentCoverUrl,
    required this.onCoverUpdated,
  });

  @override
  ConsumerState<_CoverUploadButton> createState() => _CoverUploadButtonState();
}

class _CoverUploadButtonState extends ConsumerState<_CoverUploadButton> {
  bool _showFullWidget = false;

  @override
  Widget build(BuildContext context) {
    if (_showFullWidget) {
      return CoverUploadWidget(
        currentCoverUrl: widget.currentCoverUrl,
        onCoverUpdated: (url) {
          widget.onCoverUpdated(url);
          setState(() => _showFullWidget = false);
        },
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _showFullWidget = true),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.currentCoverUrl == null ? 'Add Cover' : 'Change',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Avatar Upload Button Widget
class _AvatarUploadButton extends ConsumerStatefulWidget {
  final String? currentAvatarUrl;
  final String userEmail;
  final Function(String) onAvatarUpdated;

  const _AvatarUploadButton({
    this.currentAvatarUrl,
    required this.userEmail,
    required this.onAvatarUpdated,
  });

  @override
  ConsumerState<_AvatarUploadButton> createState() => _AvatarUploadButtonState();
}

class _AvatarUploadButtonState extends ConsumerState<_AvatarUploadButton> {
  bool _showFullWidget = false;

  @override
  Widget build(BuildContext context) {
    if (_showFullWidget) {
      return AvatarUploadWidget(
        currentAvatarUrl: widget.currentAvatarUrl,
        onAvatarUpdated: (url) {
          widget.onAvatarUpdated(url);
          setState(() => _showFullWidget = false);
        },
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _showFullWidget = true),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: widget.currentAvatarUrl != null
                  ? NetworkImage(widget.currentAvatarUrl!)
                  : null,
              child: widget.currentAvatarUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.userEmail[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            // Edit indicator
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
