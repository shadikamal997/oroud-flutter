import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/shop_model.dart';
import '../../providers/current_shop_provider.dart';

class ManageOffersScreen extends ConsumerWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(currentShopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A2A2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Offers',
          style: TextStyle(
            color: Color(0xFF2A2A2A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFFB86E45)),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: shopAsync.when(
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
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (shop) {
          if (shop == null) {
            return const Center(child: Text('Shop not found'));
          }

          if (shop.offers.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildOffersList(context, shop);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No offers yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first offer to start managing',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Will navigate to create tab
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Flexible(
                child: Text(
                  'Create Offer',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB86E45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(BuildContext context, Shop shop) {
    // Group offers by status
    final activeOffers = shop.offers.where((o) => 
      o.expiryDate == null || o.expiryDate!.isAfter(DateTime.now())
    ).toList();
    final expiredOffers = shop.offers.where((o) => 
      o.expiryDate != null && o.expiryDate!.isBefore(DateTime.now())
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active',
                  activeOffers.length.toString(),
                  Icons.local_offer,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Expired',
                  expiredOffers.length.toString(),
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  shop.offers.length.toString(),
                  Icons.inventory,
                  const Color(0xFFB86E45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Offers Section
          if (activeOffers.isNotEmpty) ...[
            const Text(
              'Active Offers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2A2A),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 16),
            ...activeOffers.map((offer) => _buildOfferCard(context, offer, true)),
            const SizedBox(height: 24),
          ],

          // Expired Offers Section
          if (expiredOffers.isNotEmpty) ...[
            const Text(
              'Expired Offers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2A2A),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 16),
            ...expiredOffers.map((offer) => _buildOfferCard(context, offer, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2A2A),
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
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferPreview offer, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          InkWell(
            onTap: () {
              // Open offer detail screen when tapping the card
              context.push('/offer/${offer.id}');
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Offer Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: offer.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.local_offer, size: 32, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Offer Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                offer.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2A2A2A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isActive ? 'ACTIVE' : 'EXPIRED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (offer.discountPercentage != null)
                          Text(
                            '${offer.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: Color(0xFFB86E45),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (offer.expiryDate != null)
                          Text(
                            'Expires: ${_formatDate(offer.expiryDate!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigate to offer detail screen - fixed route (removed 's' from offers)
                      context.push('/offer/${offer.id}');
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Flexible(
                      child: Text(
                        'Edit',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB86E45),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[200]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation(context, offer);
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Flexible(
                      child: Text(
                        'Delete',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[200]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigate to offer detail screen with stats tab
                      context.push('/offer/${offer.id}');
                    },
                    icon: const Icon(Icons.bar_chart, size: 18),
                    label: const Flexible(
                      child: Text(
                        'Stats',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Offers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2A2A),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Active Only'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter: Active Only')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Expired Only'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter: Expired Only')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Color(0xFFB86E45)),
              title: const Text('All Offers'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, OfferPreview offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Offer?'),
        content: Text('Are you sure you want to delete "${offer.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) return '${-diff} days ago';
    if (diff < 7) return 'In $diff days';
    return '${date.day}/${date.month}/${date.year}';
  }
}
