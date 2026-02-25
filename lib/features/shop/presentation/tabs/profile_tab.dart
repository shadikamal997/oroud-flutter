import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/shop_model.dart';
import '../../providers/current_shop_provider.dart';
import '../../providers/shop_dashboard_tab_provider.dart';
import '../screens/edit_shop_profile_screen.dart';
import '../screens/manage_offers_screen.dart';
import '../../../../core/widgets/pro_upgrade_modal.dart';
import '../../../../core/api/api_provider.dart';
import '../../../../core/api/api_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(currentShopProvider);

    return shopAsync.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF5F2EE),
        body: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
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
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFFF5F2EE),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                "Unable to load shop",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(currentShopProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB86E45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
      data: (shop) {
        if (shop == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F2EE),
            body: Center(
              child: Text(
                "Loading shop...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }
        return _buildShopProfile(context, shop, ref);
      },
    );
  }

  Widget _buildShopProfile(BuildContext context, Shop shop, WidgetRef ref) {
    final isPro = shop.subscriptionPlan == 'PRO' && 
                  shop.subscriptionExpiresAt != null &&
                  shop.subscriptionExpiresAt!.isAfter(DateTime.now());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(shop),
              _buildProfileInfo(context, shop, ref),
              const SizedBox(height: 16),
              
              // PRO Upgrade Banner for FREE users
              if (!isPro)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildUpgradeBanner(context),
                ),
              
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2A2A),
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOffersSection(context, shop, ref),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context, ref),
                    const SizedBox(height: 32),
                    
                    // Danger Zone Section
                    const Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDangerZone(context, ref, shop),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Shop shop) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
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
            image: shop.coverUrl != null && shop.coverUrl!.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(shop.coverUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: shop.coverUrl != null && shop.coverUrl!.isNotEmpty
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

        // Avatar positioned at bottom center
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Colors.grey[300],
                backgroundImage: shop.logoUrl != null && shop.logoUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(shop.logoUrl!)
                    : null,
                child: shop.logoUrl == null || shop.logoUrl!.isEmpty
                    ? Icon(
                        Icons.store,
                        size: 40,
                        color: Colors.grey[600],
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context, Shop shop, WidgetRef ref) {
    final isPro = shop.subscriptionPlan == 'PRO' && 
                  shop.subscriptionExpiresAt != null &&
                  shop.subscriptionExpiresAt!.isAfter(DateTime.now());
    
    return Column(
      children: [
        const SizedBox(height: 60), // Space for avatar
        
        // Shop Name with PRO Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                shop.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (isPro) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "PRO",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        
        // Subscription Expiry (for PRO users)
        if (isPro && shop.subscriptionExpiresAt != null) ...[
          const SizedBox(height: 4),
          Text(
            "PRO until ${_formatDate(shop.subscriptionExpiresAt!)}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        
        const SizedBox(height: 4),
        if (shop.cityName != null || shop.areaName != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                [shop.cityName, shop.areaName]
                    .where((e) => e != null && e.isNotEmpty)
                    .join(", "),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        if (shop.description != null && shop.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              shop.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const SizedBox(height: 20),
        _buildStatsRow(shop),
        const SizedBox(height: 16),
        
        const SizedBox(height: 20),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildStatsRow(Shop shop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Followers", shop.followersCount.toString()),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem("Offers", shop.offersCount.toString()),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem("Rating", shop.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditShopProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Flexible(
                child: Text(
                  "Edit Profile",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB86E45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageOffersScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.local_offer, size: 18),
              label: const Flexible(
                child: Text(
                  "Manage",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB86E45),
                side: const BorderSide(color: Color(0xFFB86E45), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context, Shop shop, WidgetRef ref) {
    if (shop.offers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
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
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              "No offers yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first offer to attract customers",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Switch to Create Offer tab (index 2)
                ref.read(shopDashboardTabProvider.notifier).setTab(2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB86E45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Create First Offer"),
            ),
          ],
        ),
      );
    }

    // Filter only active offers (not expired)
    final now = DateTime.now();
    final activeOffers = shop.offers.where((offer) => offer.expiryDate.isAfter(now)).toList();
    
    if (activeOffers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          children: [
            Icon(
              Icons.schedule,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            const Text(
              "No active offers",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "All your offers have expired",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeOffers.length > 4 ? 4 : activeOffers.length,
      itemBuilder: (context, index) {
        final offer = activeOffers[index];
        return _buildOfferCard(context, offer);
      },
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferPreview offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Offer Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey[200],
              child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: offer.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey[400],
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.local_offer,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                    )
                  : Icon(
                      Icons.local_offer,
                      size: 30,
                      color: Colors.grey[400],
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Offer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2A2A2A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (offer.discountPercentage != null)
                  Text(
                    "${offer.discountPercentage}% OFF",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                if (offer.expiryDate != null)
                  Text(
                    "Expires: ${_formatDate(offer.expiryDate!)}",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // View Button
          ElevatedButton(
            onPressed: () {
              // Navigate to full offer detail screen
              context.push('/offer/${offer.id}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB86E45),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text("View"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return "Today";
    if (diff == 1) return "Tomorrow";
    if (diff < 7) return "$diff days";
    return "${date.day}/${date.month}";
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          print('🔘 Logout button pressed');
          try {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      print('❌ Logout cancelled');
                      Navigator.pop(dialogContext, false);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('✅ Logout confirmed');
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              print('🚪 Starting logout process...');
              await ref.read(authProvider.notifier).logout();
              print('✅ Logout successful');
              
              if (context.mounted) {
                print('🏠 Navigating to home...');
                context.go('/');
              }
            }
          } catch (e) {
            print('❌ Logout error: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upgrade to PRO",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Unlock unlimited offers & more",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showProUpgradeModal(
                  context,
                  featureName: 'Upgrade Your Shop',
                  description: 'Get unlimited offers, boost features, and priority support for just 10 JD/month!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF8C00),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Upgrade Now",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, WidgetRef ref, Shop shop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red[600], size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete Shop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Permanently delete your shop account. This will:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildWarningPoint('Remove all your offers'),
          _buildWarningPoint('Delete all shop data'),
          _buildWarningPoint('Convert your account to a regular user'),
          _buildWarningPoint('This action cannot be undone'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteShopConfirmation(context, ref, shop),
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Flexible(
                child: Text(
                  'Delete Shop Permanently',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: Colors.red[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteShopConfirmation(BuildContext context, WidgetRef ref, Shop shop) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Shop?',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you absolutely sure you want to delete your shop?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop Name: ${shop.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Offers: ${shop.offersCount}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    'Followers: ${shop.followersCount}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action is permanent and cannot be undone.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              await _deleteShop(context, ref, shop);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Delete Forever',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteShop(BuildContext context, WidgetRef ref, Shop shop) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.red),
      ),
    );

    try {
      // Get the API client
      final apiClient = ref.read(apiClientProvider);
      
      // Call delete shop API
      await apiClient.delete('/shops/${shop.id}');
      
      // Invalidate providers to refresh data
      ref.invalidate(currentShopProvider);
      ref.invalidate(authProvider);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop deleted successfully. You are now a regular user.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
      
      // Navigate to home
      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete shop: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
