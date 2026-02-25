import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/helpers.dart';
import '../providers/claims_provider.dart';
import '../models/claim_model.dart';

class MyClaimsScreen extends ConsumerWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(myClaimsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        title: const Text(
          'My Claims',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFB86E45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: claimsAsync.when(
        data: (claims) {
          if (claims.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group claims by status
          final activeClaims = claims.where((c) => c.isActive).toList();
          final redeemedClaims = claims.where((c) => c.isRedeemed).toList();
          final expiredClaims = claims.where((c) => c.isExpired).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myClaimsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Card
                _buildSummaryCard(context, activeClaims.length, redeemedClaims.length, expiredClaims.length),
                const SizedBox(height: 24),

                // Active Claims
                if (activeClaims.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Active Claims', activeClaims.length, Colors.green),
                  const SizedBox(height: 12),
                  ...activeClaims.map((claim) => _buildClaimCard(context, claim)),
                  const SizedBox(height: 24),
                ],

                // Redeemed Claims
                if (redeemedClaims.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Redeemed Claims', redeemedClaims.length, Colors.blue),
                  const SizedBox(height: 12),
                  ...redeemedClaims.map((claim) => _buildClaimCard(context, claim)),
                  const SizedBox(height: 24),
                ],

                // Expired Claims
                if (expiredClaims.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Expired Claims', expiredClaims.length, Colors.red),
                  const SizedBox(height: 12),
                  ...expiredClaims.map((claim) => _buildClaimCard(context, claim)),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB86E45)),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load claims',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(myClaimsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB86E45),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Claims Yet',
            style: TextStyle(
              fontSize: Helpers.responsiveFontSize(context, 24, 20),
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start claiming exclusive offers!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB86E45),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse Offers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int active, int redeemed, int expired) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(context, 'Active', active, Icons.check_circle, Colors.white),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildSummaryItem(context, 'Redeemed', redeemed, Icons.redeem, Colors.white),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildSummaryItem(context, 'Expired', expired, Icons.access_time, Colors.white),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: Helpers.responsiveFontSize(context, 24, 20),
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'serif',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: Helpers.responsiveFontSize(context, 20, 18),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2A2A2A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClaimCard(BuildContext context, Claim claim) {
    final offer = claim.offer;
    final statusColor = claim.isActive
        ? Colors.green
        : claim.isRedeemed
            ? Colors.blue
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/offer/${offer.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offer Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    offer.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Offer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              claim.isActive
                                  ? Icons.check_circle
                                  : claim.isRedeemed
                                      ? Icons.redeem
                                      : Icons.access_time,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              claim.status.toDisplayString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Offer Title
                      Text(
                        offer.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2A2A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Shop Name
                      Row(
                        children: [
                          Icon(Icons.store, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              offer.shop.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Claimed Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Claimed: ${DateFormat('MMM dd, yyyy').format(claim.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),

                      // Redeemed Date (if applicable)
                      if (claim.redeemedAt != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.check, size: 14, color: Colors.blue[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Redeemed: ${DateFormat('MMM dd, yyyy').format(claim.redeemedAt!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Expiry Warning (for active claims)
                      if (claim.isActive) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.orange[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Expires: ${DateFormat('MMM dd, yyyy').format(offer.expiryDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
