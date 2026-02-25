import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/my_shop_provider.dart';
import 'package:oroud_app/core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_provider.dart';
import '../../../shared/services/image_upload_service.dart';

/// Shop settings screen for managing shop details and preferences
class ShopSettingsScreen extends ConsumerStatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  ConsumerState<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends ConsumerState<ShopSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _showInSearch = true;
  bool _acceptReviews = true;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(myShopProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: shopAsync.when(
        data: (shop) => _buildSettingsContent(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    final shopAsync = ref.watch(myShopProvider);
    
    return shopAsync.when(
      data: (shop) {
        if (shop == null) {
          return const Center(child: Text('No shop data available'));
        }

        return ListView(
      children: [
        _buildSection(
          'Shop Information',
          [
            _buildInfoTile(
              Icons.store,
              'Shop Name',
              shop.name,
              onTap: () => _showEditDialog('Shop Name', shop.name),
            ),
            _buildInfoTile(
              Icons.location_on,
              'Location',
              '${shop.city.name}, ${shop.area.name}',
            ),
            _buildInfoTile(
              Icons.verified,
              'Verification Status',
              shop.isVerified ? 'Verified ✓' : 'Not Verified',
            ),
            _buildInfoTile(
              Icons.star,
              'Trust Score',
              '${shop.trustScore}/100',
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSection(
          'Shop Images',
          [
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.primary),
              title: const Text('Shop Logo'),
              subtitle: shop.logoUrl != null 
                  ? const Text('Tap to change logo')
                  : const Text('No logo uploaded'),
              trailing: shop.logoUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(shop.logoUrl!),
                      radius: 20,
                    )
                  : null,
              onTap: () => _uploadLogo(shop.id),
            ),
            ListTile(
              leading: const Icon(Icons.wallpaper, color: AppColors.primary),
              title: const Text('Cover Image'),
              subtitle: shop.coverUrl != null
                  ? const Text('Tap to change cover')
                  : const Text('No cover uploaded'),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => _uploadCover(shop.id),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSection(
          'Contact Information',
          [
            _buildInfoTile(
              Icons.phone,
              'Phone Number',
              shop.phone ?? 'Not set',
              onTap: () => _showEditContactDialog('Phone', shop.phone, shop.id),
            ),
            _buildInfoTile(
              Icons.chat,
              'WhatsApp',
              shop.whatsapp ?? 'Not set',
              onTap: () => _showEditContactDialog('WhatsApp', shop.whatsapp, shop.id),
            ),
            _buildInfoTile(
              Icons.location_on_outlined,
              'Address',
              shop.address ?? 'Not set',
              onTap: () => _showEditContactDialog('Address', shop.address, shop.id),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSection(
          'Verification',
          [
            ListTile(
              leading: Icon(
                shop.isVerified ? Icons.verified : Icons.info_outline,
                color: shop.isVerified ? Colors.green : AppColors.primary,
              ),
              title: Text(shop.isVerified ? 'Verified Shop' : 'Request Verification'),
              subtitle: Text(
                shop.isVerified
                    ? 'Your shop is verified'
                    : 'Get verified to boost trust and visibility',
              ),
              trailing: shop.isVerified
                  ? null
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: shop.isVerified ? null : () => _requestVerification(shop.id),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSection(
          'Notifications',
          [
            _buildSwitchTile(
              Icons.notifications_active,
              'Push Notifications',
              'Receive notifications for new orders and messages',
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
            ),
            _buildSwitchTile(
              Icons.email_outlined,
              'Email Notifications',
              'Get weekly reports and updates via email',
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSection(
          'Privacy & Visibility',
          [
            _buildSwitchTile(
              Icons.search,
              'Show in Search',
              'Allow customers to find your shop in search',
              _showInSearch,
              (value) => setState(() => _showInSearch = value),
            ),
            _buildSwitchTile(
              Icons.star_outline,
              'Accept Reviews',
              'Allow customers to leave reviews for your shop',
              _acceptReviews,
              (value) => setState(() => _acceptReviews = value),
            ),
          ],
        ),
        const Divider(height: 32),
        _buildSection(
          'Account Management',
          [
            _buildActionTile(
              Icons.lock_outline,
              'Change Password',
              AppColors.primary,
              () => _showChangePasswordDialog(),
            ),
            _buildActionTile(
              Icons.logout,
              'Logout',
              Colors.orange,
              () => _showLogoutDialog(),
            ),
            _buildActionTile(
              Icons.delete_outline,
              'Deactivate Shop',
              Colors.red,
              () => _showDeactivateDialog(),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.edit, size: 20) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: _isSaving ? null : (newValue) async {
        // Update locally first
        onChanged(newValue);
        
        // Save to backend
        await _saveSettings();
      },
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: color),
      onTap: onTap,
    );
  }

  void _showEditDialog(String field, String? currentValue) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                context.pop();
                await _updateShopName(newValue);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    try {
      final shopAsync = ref.read(myShopProvider);
      final shop = shopAsync.value;
      
      if (shop == null) return;
      
      final api = ref.read(apiClientProvider);
      await api.put(
        '/shops/${shop.id}/settings',
        data: {
          'pushNotifications': _pushNotifications,
          'emailNotifications': _emailNotifications,
          'showInSearch': _showInSearch,
          'acceptReviews': _acceptReviews,
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _updateShopName(String newName) async {
    try {
      final shopAsync = ref.read(myShopProvider);
      final shop = shopAsync.value;
      
      if (shop == null) return;
      
      final api = ref.read(apiClientProvider);
      await api.patch(
        '/shops/${shop.id}/name',
        data: {'name': newName},
      );
      
      // Refresh shop data
      ref.invalidate(myShopProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop name updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password change via auth module
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password change - use profile settings'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop(); // Close dialog first
              
              try {
                // Perform logout
                await ref.read(authProvider.notifier).logout();
                
                if (mounted) {
                  // Navigate to home screen
                  context.go('/');
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Shop'),
        content: const Text(
          'Are you sure you want to deactivate your shop? '
          'Your offers will be hidden and customers won\'t be able to find your shop. '
          'You can reactivate it anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await _deactivateShop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateShop() async {
    try {
      final shopAsync = ref.read(myShopProvider);
      final shop = shopAsync.value;
      
      if (shop == null) return;
      
      final api = ref.read(apiClientProvider);
      await api.post('/shops/${shop.id}/deactivate');
      
      // Log out user after deactivation
      await ref.read(authProvider.notifier).logout();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop deactivated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to home screen
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to deactivate shop: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Logo upload
  Future<void> _uploadLogo(String shopId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading logo...')),
        );
      }

      // Upload image
      final uploadService = ref.read(imageUploadServiceProvider);
      final imageUrl = await uploadService.uploadImageFromPath(image.path);

      // Update shop
      final api = ref.read(apiClientProvider);
      await api.put(
        '/shops/$shopId/images',
        data: {'logo': imageUrl},
      );

      // Refresh shop data
      ref.invalidate(myShopProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Cover image upload
  Future<void> _uploadCover(String shopId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading cover image...')),
        );
      }

      // Upload image
      final uploadService = ref.read(imageUploadServiceProvider);
      final imageUrl = await uploadService.uploadImageFromPath(image.path);

      // Update shop
      final api = ref.read(apiClientProvider);
      await api.put(
        '/shops/$shopId/images',
        data: {'coverImage': imageUrl},
      );

      // Refresh shop data
      ref.invalidate(myShopProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cover image updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload cover: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

 // Edit contact dialog
  void _showEditContactDialog(String field, String? currentValue, String shopId) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
          keyboardType: field == 'Phone' || field == 'WhatsApp'
              ? TextInputType.phone
              : TextInputType.text,
          maxLines: field == 'Address' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              Navigator.pop(context);
              await _updateContact(shopId, field, newValue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateContact(String shopId, String field, String value) async {
    try {
      final api = ref.read(apiClientProvider);
      final data = <String, String>{};

      if (field == 'Phone') {
        data['phone'] = value;
      } else if (field == 'WhatsApp') {
        data['whatsapp'] = value;
      } else if (field == 'Address') {
        data['address'] = value;
      }

      await api.put('/shops/$shopId/contact', data: data);

      // Refresh shop data
      ref.invalidate(myShopProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $field: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestVerification(String shopId) async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post('/shops/$shopId/request-verification');

      // Refresh shop data to show new verified status
      ref.invalidate(myShopProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Shop verified successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
