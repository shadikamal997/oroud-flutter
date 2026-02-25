import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/admin_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Admin Panel'),
        backgroundColor: const Color(0xFFB86E45),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'Shops'),
            Tab(icon: Icon(Icons.local_offer), text: 'Offers'),
            Tab(icon: Icon(Icons.flag), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ShopsTab(),
          _OffersTab(),
          _ReportsTab(),
        ],
      ),
    );
  }
}

// Shops Tab
class _ShopsTab extends ConsumerWidget {
  const _ShopsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(adminShopsProvider);

    return shopsAsync.when(
      data: (shops) {
        if (shops.isEmpty) {
          return const Center(child: Text('No shops found'));
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminShopsProvider.future),
          child: ListView.builder(
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return _ShopCard(shop: shop);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ShopCard extends ConsumerWidget {
  final Map<String, dynamic> shop;

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = shop['isVerified'] ?? false;
    final trustScore = shop['trustScore'] ?? 0;
    final isActive = shop['user']?['isActive'] ?? true;

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isVerified ? Colors.green : AppColors.primary,
          child: Icon(
            isVerified ? Icons.verified : Icons.store,
            color: Colors.white,
          ),
        ),
        title: Text(
          shop['name'] ?? 'Unknown Shop',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${shop['city']?['name']} - ${shop['area']?['name']}'),
            Text('Trust: $trustScore | Offers: ${shop['_count']?['offers'] ?? 0}'),
            if (!isActive)
              const Text(
                'BLOCKED',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!isVerified)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Verify Shop'),
                  ],
                ),
                onTap: () async {
                  await ref.read(adminServiceProvider).verifyShop(shop['id']);
                  ref.invalidate(adminShopsProvider);
                },
              ),
            if (isActive)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block Shop'),
                  ],
                ),
                onTap: () async {
                  await ref.read(adminServiceProvider).blockShop(shop['id']);
                  ref.invalidate(adminShopsProvider);
                },
              ),
            if (!isActive)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Unblock Shop'),
                  ],
                ),
                onTap: () async {
                  await ref.read(adminServiceProvider).unblockShop(shop['id']);
                  ref.invalidate(adminShopsProvider);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Offers Tab
class _OffersTab extends ConsumerWidget {
  const _OffersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(adminOffersProvider);

    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) {
          return const Center(child: Text('No offers found'));
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminOffersProvider.future),
          child: ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return _OfferCard(offer: offer);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _OfferCard extends ConsumerWidget {
  final Map<String, dynamic> offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuspicious = offer['isSuspicious'] ?? false;
    final reportCount = offer['reportCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.all(8),
      color: isSuspicious ? Colors.red.shade50 : null,
      child: ListTile(
        leading: Icon(
          isSuspicious ? Icons.warning : Icons.local_offer,
          color: isSuspicious ? Colors.red : Colors.blue,
        ),
        title: Text(
          offer['title'] ?? 'Unknown Offer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shop: ${offer['shop']?['name'] ?? 'Unknown'}'),
            Text('${offer['city']?['name']} - ${offer['area']?['name']}'),
            if (reportCount > 0)
              Text(
                '⚠️ $reportCount reports',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Offer'),
                ],
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Offer'),
                    content: const Text('Are you sure? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(adminServiceProvider).deleteOffer(offer['id']);
                  ref.invalidate(adminOffersProvider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reports Tab
class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(child: Text('No reports found'));
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminReportsProvider.future),
          child: ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _ReportCard(report: report);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(Icons.flag, color: Colors.red),
        title: Text(
          report['offer']?['title'] ?? 'Unknown Offer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason: ${report['reason'] ?? 'No reason provided'}'),
            Text('Shop: ${report['offer']?['shop']?['name'] ?? 'Unknown'}'),
            Text('Reported by: ${report['user']?['email'] ?? report['user']?['phone'] ?? 'Unknown'}'),
          ],
        ),
      ),
    );
  }
}
