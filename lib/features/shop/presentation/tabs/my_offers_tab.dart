import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/api_provider.dart';
import '../../models/shop_model.dart';
import '../../providers/current_shop_provider.dart';
import '../../providers/shop_dashboard_tab_provider.dart';

class MyOffersTab extends ConsumerStatefulWidget {
  const MyOffersTab({super.key});

  @override
  ConsumerState<MyOffersTab> createState() => _MyOffersTabState();
}

class _MyOffersTabState extends ConsumerState<MyOffersTab> {
  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(currentShopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: shopAsync.when(
          loading: () => Center(
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
          error: (error, stack) => Center(
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
                  "Unable to load offers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentShopProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB86E45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
          data: (shop) {
            if (shop == null) {
              return const Center(
                child: Text(
                  "Loading offers...",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Empty state
            if (shop.offers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with modern gradient
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFB86E45).withValues(alpha: 0.2),
                                  const Color(0xFFCC7F54).withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.local_offer_outlined,
                              size: 50,
                              color: Color(0xFFB86E45),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "No offers yet",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2A2A),
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Start creating amazing offers to attract more customers",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to create offer tab (index 2)
                              ref.read(shopDashboardTabProvider.notifier).setTab(2);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Center(
                              child: Text(
                                "Create First Offer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

          // Offers list - Modern Grid Layout
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_offer_rounded,
                        color: Color(0xFFB86E45),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "My Offers",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A2A2A),
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${shop.offers.length} ${shop.offers.length == 1 ? 'Offer' : 'Offers'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Manage and track your active offers",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Grid Layout (3 columns like home screen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: shop.offers.length,
                    itemBuilder: (context, index) {
                      final offer = shop.offers[index];
                      return _buildModernOfferCard(context, ref, offer);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  // Modern Offer Card (Grid View Style)
  Widget _buildModernOfferCard(BuildContext context, WidgetRef ref, OfferPreview offer) {
    final isExpired = offer.expiryDate.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () => context.push('/offer/${offer.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: offer.imageUrl!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 110,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFB86E45),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 110,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          height: 110,
                          color: Colors.grey[200],
                          child: const Icon(Icons.local_offer, size: 40, color: Colors.grey),
                        ),
                ),
                // Status Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired 
                          ? Colors.grey 
                          : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired ? "EXPIRED" : "ACTIVE",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Discount Badge
                if (offer.discountPercentage != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${offer.discountPercentage}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      offer.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2A2A2A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Prices
                    if (offer.discountedPrice != null)
                      Row(
                        children: [
                          Text(
                            "JD ${offer.discountedPrice!.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB86E45),
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (offer.originalPrice != null)
                            Flexible(
                              child: Text(
                                "JD ${offer.originalPrice!.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Original List View Card (kept for reference, can be removed if not used)
  Widget _buildOfferCard(BuildContext context, WidgetRef ref, OfferPreview offer) {
    final isExpired = offer.expiryDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          // Left: Offer Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: offer.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.local_offer,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(
                    Icons.local_offer,
                    size: 30,
                    color: Colors.grey[400],
                  ),
          ),

          const SizedBox(width: 16),

          // Right: Offer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Prices
                Row(
                  children: [
                    // Discounted Price
                    if (offer.discountedPrice != null)
                      Text(
                        "JD ${offer.discountedPrice!.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB86E45),
                        ),
                      ),
                    const SizedBox(width: 8),

                    // Original Price (strikethrough)
                    if (offer.originalPrice != null)
                      Text(
                        "JD ${offer.originalPrice!.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isExpired ? Colors.grey : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isExpired ? "EXPIRED" : "ACTIVE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trailing: 3-dot menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pause',
                child: Row(
                  children: [
                    Icon(Icons.pause_circle, size: 20, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Pause'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  _showEditDialog(context, ref, offer);
                  break;
                case 'pause':
                  await _toggleOfferStatus(context, ref, offer);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, ref, offer);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, OfferPreview offer) {
    // Navigate to offer detail screen (edit functionality to be added later)
    context.push('/offer/${offer.id}');
  }

  Future<void> _toggleOfferStatus(BuildContext context, WidgetRef ref, OfferPreview offer) async {
    try {
      final api = ref.read(apiClientProvider);
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updating offer status..."),
          duration: Duration(seconds: 1),
        ),
      );

      // Toggle pause status (assuming backend has this endpoint)
      await api.patch('/offers/${offer.id}/toggle-status');

      // Refresh shop data
      ref.invalidate(currentShopProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Offer status updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update offer: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, OfferPreview offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Delete Offer?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete \"${offer.title}\"?",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This action cannot be undone",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteOffer(context, ref, offer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOffer(BuildContext context, WidgetRef ref, OfferPreview offer) async {
    try {
      final api = ref.read(apiClientProvider);
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deleting offer..."),
          duration: Duration(seconds: 1),
        ),
      );

      // Delete offer
      await api.delete('/offers/${offer.id}');

      // Refresh shop data
      ref.invalidate(currentShopProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Offer deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete offer: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
