import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/my_shop_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/my_offers_provider.dart';
import '../models/shop_analytics_model.dart';
import '../../../shared/models/shop_model.dart';
import '../../auth/providers/auth_provider.dart';

// ─── Design Constants ─────────────────────────────────────────────────────────
const _backgroundColor = Color(0xFFF5F2EE);
const _primaryColor    = Color(0xFFB86E45);
const _textDark        = Color(0xFF2D2D2D);
const _textMuted       = Color(0xFF8B8B8B);

// ─── Number Formatter ─────────────────────────────────────────────────────────
String _formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class ShopDashboardScreen extends ConsumerWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync      = ref.watch(myShopProvider);
    final analyticsAsync = ref.watch(shopAnalyticsProvider);
    final offersState    = ref.watch(myOffersProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) context.go('/');
          },
        ),
        title: const Text('Shop Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: shopAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(myShopProvider),
        ),
        data: (shop) {
          if (shop == null) return const _NoShopView();
          return RefreshIndicator(
            color: _primaryColor,
            onRefresh: () async {
              ref.invalidate(myShopProvider);
              ref.invalidate(shopAnalyticsProvider);
              ref.read(myOffersProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _Header(
                    shop: shop,
                    analyticsAsync: analyticsAsync,
                    offersState: offersState,
                  ),
                  const SizedBox(height: 140),
                  _OffersSection(offersState: offersState),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Header Stack ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final Shop shop;
  final AsyncValue<ShopAnalytics> analyticsAsync;
  final MyOffersState offersState;

  const _Header({
    required this.shop,
    required this.analyticsAsync,
    required this.offersState,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CoverImage(coverUrl: shop.coverUrl),
        _GradientOverlay(),
        _TopActions(),
        Positioned(
          bottom: -120,
          left: 16,
          right: 16,
          child: _FloatingCard(
            shop: shop,
            analyticsAsync: analyticsAsync,
            offersState: offersState,
          ),
        ),
      ],
    );
  }
}

// ─── Cover Image ──────────────────────────────────────────────────────────────
class _CoverImage extends StatelessWidget {
  final String? coverUrl;
  const _CoverImage({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.15),
        image: coverUrl != null
            ? DecorationImage(
                image: NetworkImage(coverUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: coverUrl == null
          ? const Center(child: Icon(Icons.store, size: 72, color: _primaryColor))
          : null,
    );
  }
}

// ─── Gradient Overlay ─────────────────────────────────────────────────────────
class _GradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Top Action Icons ─────────────────────────────────────────────────────────
class _TopActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.of(context).padding.top + 8;
    return Positioned(
      top: top,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // EMERGENCY LOGOUT BUTTON - Always visible
          GestureDetector(
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Logout', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _iconBtn(context, Icons.notifications_outlined, '/shop/notifications'),
              const SizedBox(width: 8),
              _iconBtn(context, Icons.settings_outlined, '/shop/settings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, String route) =>
      GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

// ─── Floating White Card ──────────────────────────────────────────────────────
class _FloatingCard extends StatelessWidget {
  final Shop shop;
  final AsyncValue<ShopAnalytics> analyticsAsync;
  final MyOffersState offersState;

  const _FloatingCard({
    required this.shop,
    required this.analyticsAsync,
    required this.offersState,
  });

  @override
  Widget build(BuildContext context) {
    final description = [shop.area.name, shop.city.name]
        .where((s) => s.isNotEmpty)
        .join(' \u2022 ');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Logo(logoUrl: shop.logoUrl),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  shop.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
              ),
              if (shop.isPremium) ...[
                const SizedBox(width: 6),
                const _ProBadge(),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _textMuted),
          ),
          const SizedBox(height: 16),
          _StatsRow(analyticsAsync: analyticsAsync, offersState: offersState),
          const SizedBox(height: 20),
          _ConnectedButtons(),
        ],
      ),
    );
  }
}

// ─── Logo ─────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  final String? logoUrl;
  const _Logo({this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -48),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 36,
            backgroundColor: _primaryColor.withValues(alpha: 0.1),
            backgroundImage: logoUrl != null ? NetworkImage(logoUrl!) : null,
            child: logoUrl == null
                ? const Icon(Icons.store, size: 32, color: _primaryColor)
                : null,
          ),
        ),
      ),
    );
  }
}

// ─── PRO Badge ────────────────────────────────────────────────────────────────
class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AsyncValue<ShopAnalytics> analyticsAsync;
  final MyOffersState offersState;

  const _StatsRow({required this.analyticsAsync, required this.offersState});

  @override
  Widget build(BuildContext context) {
    return analyticsAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor),
          ),
        ),
      ),
      error: (e, _) => const _StatItem(label: 'Stats', value: '—'),
      data: (analytics) {
        final activeCount = offersState.maybeWhen(
          loaded: (data) => data.summary.active,
          orElse: () => analytics.activeOffersCount,
        );
        return Row(
          children: [
            Expanded(child: _StatItem(label: 'Views', value: _formatCount(analytics.totalViews))),
            _VDivider(),
            Expanded(child: _StatItem(label: 'Saves', value: _formatCount(analytics.totalSaves))),
            _VDivider(),
            Expanded(child: _StatItem(label: 'Offers', value: _formatCount(activeCount))),
          ],
        );
      },
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 32, width: 1, color: const Color(0xFFE8E8E8));
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: _textMuted),
        ),
      ],
    );
  }
}

// ─── Connected Buttons ────────────────────────────────────────────────────────
class _ConnectedButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/shop/settings'),
            child: Container(
              height: 48,
              decoration: const BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Edit Profile',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/shop/my-offers'),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _primaryColor),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Manage Offers',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Offers Section ───────────────────────────────────────────────────────────
class _OffersSection extends StatelessWidget {
  final MyOffersState offersState;
  const _OffersSection({required this.offersState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  )),
              GestureDetector(
                onTap: () => context.push('/shop/my-offers'),
                child: const Text('See All',
                    style: TextStyle(
                      fontSize: 13,
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          offersState.when(
            initial: () => const _OffersPlaceholder(),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: _primaryColor),
              ),
            ),
            error: (msg) => _OffersError(message: msg),
            loaded: (data) {
              final active = data.offers.active;
              if (active.isEmpty) {
                return _EmptyOffers(onTap: () => context.push('/shop/create-offer'));
              }
              // Use Column instead of ListView for better layout stability
              final displayCount = active.length > 5 ? 5 : active.length;
              return Column(
                children: [
                  for (int i = 0; i < displayCount; i++) ...[
                    _OfferCard(offer: active[i] as Map<String, dynamic>),
                    if (i < displayCount - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/shop/create-offer'),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Flexible(
                child: Text(
                  'Create New Offer',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _QuickActionsRow(),
        ],
      ),
    );
  }
}

// ─── Offer Card ───────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final imageUrls = offer['imageUrls'] as List<dynamic>? ?? [];
    final imageUrl  = imageUrls.isNotEmpty ? imageUrls.first as String : null;
    final title     = offer['title'] as String? ?? 'Offer';
    final views     = offer['views'] as int? ?? 0;
    final saves     = offer['saves'] as int? ?? 0;
    final discount  = (offer['discountPercentage'] as num?)?.toDouble() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: imageUrl != null
                ? Image.network(imageUrl,
                    width: 88, height: 88, fit: BoxFit.cover,
                    errorBuilder: (_, e, stackTrace) => _fallback)
                : _fallback,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textDark,
                      )),
                  const SizedBox(height: 6),
                  Row(children: [
                    _chip(Icons.visibility_outlined, '$views'),
                    const SizedBox(width: 8),
                    _chip(Icons.bookmark_outline, '$saves'),
                  ]),
                ],
              ),
            ),
          ),
          if (discount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('-${discount.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )),
              ),
            ),
        ],
      ),
    );
  }

  Widget get _fallback => Container(
        width: 88, height: 88,
        color: _primaryColor.withValues(alpha: 0.1),
        child: const Icon(Icons.local_offer, color: _primaryColor),
      );

  Widget _chip(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _textMuted),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: _textMuted)),
        ],
      );
}

// ─── Quick Actions Row ────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickBtn(icon: Icons.bar_chart_rounded, label: 'Analytics',
            onTap: () => context.push('/shop/analytics')),
        const SizedBox(width: 12),
        _QuickBtn(icon: Icons.notifications_outlined, label: 'Notifications',
            onTap: () => context.push('/shop/notifications')),
        const SizedBox(width: 12),
        _QuickBtn(icon: Icons.workspace_premium_outlined, label: 'Premium',
            onTap: () => context.push('/shop/premium-upgrade')),
      ],
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _primaryColor, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textDark,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Error / Placeholder States ──────────────────────────────────────
class _EmptyOffers extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyOffers({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: _primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryColor.withValues(alpha: 0.25)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: _primaryColor, size: 32),
            SizedBox(height: 8),
            Text('No active offers — tap to create one',
                style: TextStyle(color: _primaryColor, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _OffersPlaceholder extends StatelessWidget {
  const _OffersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
      )),
    );
  }
}

class _OffersError extends StatelessWidget {
  final String message;
  const _OffersError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Could not load offers',
                style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Shop',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textMuted),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoShopView extends ConsumerWidget {
  const _NoShopView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_mall_directory_outlined,
                size: 72,
                color: _primaryColor.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            const Text(
              "You don't have a shop yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Register your shop to start creating offers and growing your business.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/shop/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Register My Shop',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                context.go('/');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Logout',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
