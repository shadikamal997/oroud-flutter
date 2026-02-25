import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/my_offers_provider.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/boost_to_slider_dialog.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

/// My offers screen with tabs for active, expired, and inactive offers
class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Active'),
                  const SizedBox(width: 6),
                  if (state.maybeWhen(
                    orElse: () => false,
                    loaded: (data) => true,
                  ))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        state.maybeWhen(
                          orElse: () => '0',
                          loaded: (data) =>
                              data.summary.active.toString(),
                        ),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Expired'),
                  const SizedBox(width: 6),
                  if (state.maybeWhen(
                    orElse: () => false,
                    loaded: (data) => true,
                  ))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        state.maybeWhen(
                          orElse: () => '0',
                          loaded: (data) =>
                              data.summary.expired.toString(),
                        ),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Inactive'),
                  const SizedBox(width: 6),
                  if (state.maybeWhen(
                    orElse: () => false,
                    loaded: (data) => true,
                  ))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        state.maybeWhen(
                          orElse: () => '0',
                          loaded: (data) =>
                              data.summary.inactive.toString(),
                        ),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(myOffersProvider.notifier).refresh(),
        child: state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (data) => TabBarView(
            controller: _tabController,
            children: [
              _buildOffersList(data.offers.active),
              _buildOffersList(data.offers.expired),
              _buildOffersList(data.offers.inactive),
            ],
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(myOffersProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/shop/create-offer');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create Offer'),
      ),
    );
  }

  Widget _buildOffersList(List<dynamic> offers) {
    if (offers.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.local_offer_outlined,
        title: 'No offers here yet',
        subtitle: 'Start creating amazing offers to attract customers and grow your business!',
        actionLabel: 'Create Your First Offer',
        onAction: () => context.push('/shop/create-offer'),
        color: AppColors.primary,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _buildOfferCard(offer);
      },
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final analytics = offer['analytics'] as Map<String, dynamic>?;
    final views = analytics?['views'] ?? 0;
    final saves = analytics?['saves'] ?? 0;
    final clicks = analytics?['clicks'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to offer detail for editing
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Offer image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  offer['imageUrl'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Offer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['title'] ?? 'Untitled',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${offer['discountPercent'] ?? 0}% OFF',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (offer['isActive'] == true)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Analytics
                    Row(
                      children: [
                        _buildAnalyticChip(
                          Icons.visibility_outlined,
                          views.toString(),
                        ),
                        const SizedBox(width: 8),
                        _buildAnalyticChip(
                          Icons.bookmark_outline,
                          saves.toString(),
                        ),
                        const SizedBox(width: 8),
                        _buildAnalyticChip(
                          Icons.touch_app_outlined,
                          clicks.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action menu
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'boost',
                    child: Row(
                      children: [
                        Icon(Icons.rocket_launch, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Boost to Premium Slider', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off, size: 20),
                        SizedBox(width: 8),
                        Text('Deactivate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  final offerId = offer['id'] as String;
                  final offerTitle = offer['title'] as String? ?? 'Untitled';
                  
                  if (value == 'boost') {
                    // Show boost dialog
                    final success = await showDialog<bool>(
                      context: context,
                      builder: (context) => BoostToSliderDialog(
                        offerId: offerId,
                        offerTitle: offerTitle,
                      ),
                    );
                    
                    if (success == true && mounted) {
                      // Refresh offers to show updated boost status
                      await ref.read(myOffersProvider.notifier).refresh();
                    }
                  } else if (value == 'edit') {
                    // TODO: Navigate to edit screen
                    context.push('/shop/edit-offer/$offerId');
                  } else if (value == 'deactivate') {
                    // Toggle isActive status
                    try {
                      await ref.read(myOffersProvider.notifier).updateOffer(
                        offerId,
                        {'isActive': !(offer['isActive'] as bool? ?? true)},
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              offer['isActive'] == true
                                  ? 'Offer deactivated'
                                  : 'Offer activated',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update offer: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else if (value == 'delete') {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Offer'),
                        content: const Text(
                          'Are you sure you want to delete this offer? This cannot be undone.',
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
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      try {
                        await ref.read(myOffersProvider.notifier).deleteOffer(offerId);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Offer deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete offer: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticChip(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
