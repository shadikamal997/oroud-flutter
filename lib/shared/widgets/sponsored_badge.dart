import 'package:flutter/material.dart';

/// Sponsored badge overlay for offer cards
/// Place this widget on top of offer image using Stack/Positioned
class SponsoredBadge extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const SponsoredBadge({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Sponsored',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example usage in offer card:
/// ```dart
/// Stack(
///   children: [
///     Image.network(offer.imageUrl),
///     if (offer.isSponsored)
///       Positioned(
///         top: 0,
///         left: 0,
///         child: SponsoredBadge(),
///       ),
///   ],
/// )
/// ```
