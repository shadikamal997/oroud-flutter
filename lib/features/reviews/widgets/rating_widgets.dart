import 'package:flutter/material.dart';

/// Star Rating Display - Shows rating as stars (read-only)
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int totalStars;
  final double size;
  final Color filledColor;
  final Color emptyColor;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.totalStars = 5,
    this.size = 16,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalStars, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: filledColor);
        } else if (index < rating && rating % 1 != 0) {
          return Icon(Icons.star_half, size: size, color: filledColor);
        } else {
          return Icon(Icons.star_border, size: size, color: emptyColor);
        }
      }),
    );
  }
}

/// Star Rating Selector - Interactive star rating input
class StarRatingSelector extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  final double size;

  const StarRatingSelector({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  State<StarRatingSelector> createState() => _StarRatingSelectorState();
}

class _StarRatingSelectorState extends State<StarRatingSelector> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starIndex;
            });
            widget.onRatingChanged(starIndex);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starIndex <= _currentRating ? Icons.star : Icons.star_border,
              size: widget.size,
              color: starIndex <= _currentRating
                  ? Colors.amber
                  : Colors.grey,
            ),
          ),
        );
      }),
    );
  }
}

/// Compact Rating Badge - Shows rating with review count
class RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool showCount;

  const RatingBadge({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewCount == 0) {
      return const Text(
        'No reviews yet',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
