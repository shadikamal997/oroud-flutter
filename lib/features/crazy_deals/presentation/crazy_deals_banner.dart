import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/crazy_deals_provider.dart';
import '../../../shared/widgets/offer_card.dart';

class CrazyDealsBanner extends ConsumerWidget {
  const CrazyDealsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDeals = ref.watch(crazyDealsProvider);

    return asyncDeals.when(
      data: (offers) {
        if (offers.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "🔥 Today's Crazy Deals",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 280,
                    child: OfferCard(offer: offers[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
