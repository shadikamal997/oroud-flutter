import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_provider.dart';
import 'widgets/delete_account_dialog.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool pushEnabled = true;
  bool followShopPush = true;
  bool categoryPush = true;
  bool marketingPush = false;
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => isLoading = true);

    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/auth/profile');

      if (response.data != null) {
        setState(() {
          pushEnabled = response.data['pushEnabled'] ?? true;
          followShopPush = response.data['followShopPush'] ?? true;
          categoryPush = response.data['categoryPush'] ?? true;
          marketingPush = response.data['marketingPush'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => isSaving = true);

    try {
      final api = ref.read(apiClientProvider);
      await api.patch(
        "/users/me/settings",
        data: {
          "pushEnabled": pushEnabled,
          "followShopPush": followShopPush,
          "categoryPush": categoryPush,
          "marketingPush": marketingPush,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Settings updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update settings: $e"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFFB86E45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
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
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Notifications Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Notifications",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Control what notifications you receive",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Master Push Toggle
                      _buildSettingTile(
                        icon: Icons.notifications_active,
                        title: "Enable Push Notifications",
                        subtitle: "Receive all push notifications",
                        value: pushEnabled,
                        onChanged: (val) {
                          setState(() => pushEnabled = val);
                        },
                      ),
                      const Divider(height: 20),

                      // Followed Shops Toggle
                      _buildSettingTile(
                        icon: Icons.store,
                        iconColor: pushEnabled ? null : Colors.grey,
                        title: "Followed Shops Alerts",
                        subtitle: "New offers from shops you follow",
                        value: followShopPush,
                        enabled: pushEnabled,
                        onChanged: pushEnabled
                            ? (val) {
                                setState(() => followShopPush = val);
                              }
                            : null,
                      ),
                      const Divider(height: 20),

                      // Category Alerts Toggle
                      _buildSettingTile(
                        icon: Icons.category,
                        iconColor: pushEnabled ? null : Colors.grey,
                        title: "Category Alerts",
                        subtitle: "Offers in your favorite categories",
                        value: categoryPush,
                        enabled: pushEnabled,
                        onChanged: pushEnabled
                            ? (val) {
                                setState(() => categoryPush = val);
                              }
                            : null,
                      ),
                      const Divider(height: 20),

                      // Marketing Toggle
                      _buildSettingTile(
                        icon: Icons.campaign,
                        iconColor: pushEnabled ? null : Colors.grey,
                        title: "Marketing Messages",
                        subtitle: "Promotional offers and updates",
                        value: marketingPush,
                        enabled: pushEnabled,
                        onChanged: pushEnabled
                            ? (val) {
                                setState(() => marketingPush = val);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Email Notifications (Coming Soon)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.email_outlined,
                              color: Colors.grey.shade500,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email Notifications",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Coming Soon",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Privacy & Legal Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.privacy_tip_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Privacy & Legal",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFFB86E45),
                        ),
                        title: const Text("Change Password"),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          context.push('/change-password');
                        },
                      ),
                      const Divider(height: 1),

                      // Privacy Policy
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.policy_outlined,
                          color: Color(0xFFB86E45),
                        ),
                        title: const Text("Privacy Policy"),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Privacy Policy - Coming Soon'),
                            ),
                          );
                        },
                      ),

                      // Terms of Service
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFFB86E45),
                        ),
                        title: const Text("Terms of Service"),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Terms of Service - Coming Soon'),
                            ),
                          );
                        },
                      ),

                      // Help & Support
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.help_outline,
                          color: Color(0xFFB86E45),
                        ),
                        title: const Text("Help & Support"),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          context.push('/help-support');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Legal Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.policy_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Legal",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.privacy_tip_outlined,
                          color: Color(0xFFB86E45),
                        ),
                        title: const Text(
                          "Privacy Policy",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: const Text(
                          'How we handle your data',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFFB86E45),
                        ),
                        title: const Text(
                          "Terms of Service",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: const Text(
                          'Rules and guidelines',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
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
                ),
                const SizedBox(height: 24),

                // Danger Zone (Optional)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.warning_outlined,
                              color: Colors.red.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Danger Zone",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_forever,
                          color: Colors.red.shade700,
                        ),
                        title: Text(
                          "Delete Account",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Permanently delete your account',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.red,
                        ),
                        onTap: () {
                          showDeleteAccountDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB86E45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
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
                        : const Text(
                            "Save Settings",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required bool value,
    bool enabled = true,
    required void Function(bool)? onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFFB86E45)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFFB86E45),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: enabled ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFFB86E45),
        ),
      ],
    );
  }
}
