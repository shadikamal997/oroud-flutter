import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/discount_badge.dart';
import '../models/offer_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/api/api_provider.dart';
import '../providers/saved_provider.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const OfferDetailScreen({super.key, required this.offer});

  @override
  ConsumerState<OfferDetailScreen> createState() =>
      _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _trackView();
  }

  void _trackView() {
    try {
      final api = ref.read(apiClientProvider);
      api.post('/offers/${widget.offer.id}/analytics', data: {'type': 'view'});
    } catch (e) {
      // Silent fail for analytics
    }
  }

  void _handleSave() async {
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/offers/${widget.offer.id}/analytics', data: {'type': 'save'});

      setState(() {
        isSaved = !isSaved;
      });

      // Refresh saved offers list
      ref.invalidate(savedOffersProvider);

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSaved ? "Saved successfully ❤️" : "Removed from saved",
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: isSaved ? const Color(0xFFF97316) : Colors.grey,
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleClick() async {
    try {
      final api = ref.read(apiClientProvider);
      api.post('/offers/${widget.offer.id}/analytics', data: {'type': 'click'});

      // Open in maps
      final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${widget.offer.shop.name}",
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: _buildContent(context),
              ),
            ],
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            Share.share(
              "Check this offer: ${widget.offer.title}",
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.offer.imageUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 60,
              right: 20,
              child: DiscountBadge(
                percentage: widget.offer.discountPercentage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final remaining = widget.offer.expiryDate.difference(DateTime.now());

    if (remaining.isNegative) {
      return const Text(
        "Expired",
        style: TextStyle(color: Colors.red),
      );
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Ends in $hours h $minutes m",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.offer.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "${widget.offer.discountedPrice} JOD",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${widget.offer.originalPrice} JOD",
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCountdown(),
          const SizedBox(height: 20),
          const Text(
            "Offer Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Limited time offer. Visit the shop before expiry date.",
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.store),
              const SizedBox(width: 8),
              Text(widget.offer.shop.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleClick,
              child: const Text("Get This Offer"),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _handleSave,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey),
            ),
            icon: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: isSaved ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
