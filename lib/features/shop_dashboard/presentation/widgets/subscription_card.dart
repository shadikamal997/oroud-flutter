import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionCard extends StatelessWidget {
  final String plan;
  final int activeOffers;
  final int? limit;
  final DateTime? expiresAt;
  final VoidCallback? onUpgrade;

  const SubscriptionCard({
    super.key,
    required this.plan,
    required this.activeOffers,
    this.limit,
    this.expiresAt,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = plan == 'PRO';
    final isNearLimit = !isPro && limit != null && activeOffers >= (limit! * 0.8);
    final isAtLimit = !isPro && limit != null && activeOffers >= limit!;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPro
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPro ? Icons.verified : Icons.workspace_premium_outlined,
                color: isPro ? Colors.black87 : Colors.indigo,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isPro ? "PRO Plan" : "FREE Plan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isPro ? Colors.black87 : Colors.indigo[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // FREE plan - show offer count
          if (!isPro && limit != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAtLimit
                    ? Colors.red.shade50
                    : isNearLimit
                        ? Colors.orange.shade50
                        : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isAtLimit
                        ? Icons.warning_amber_rounded
                        : Icons.local_offer_outlined,
                    color: isAtLimit
                        ? Colors.red
                        : isNearLimit
                            ? Colors.orange
                            : Colors.indigo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$activeOffers / $limit offers used",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isAtLimit
                                ? Colors.red.shade700
                                : Colors.black87,
                          ),
                        ),
                        if (isAtLimit)
                          Text(
                            "Limit reached! Upgrade to continue.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade600,
                            ),
                          ),
                        if (isNearLimit && !isAtLimit)
                          Text(
                            "Almost at limit. Consider upgrading.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // PRO plan - show expiry date
          if (isPro && expiresAt != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.black87),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Active until",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(expiresAt!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "✓ Unlimited offers\n✓ Verified badge\n✓ Priority support",
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Upgrade button (only for FREE plan)
          if (!isPro)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upgrade, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isAtLimit
                          ? "Upgrade Now – 9.99 JD/month"
                          : "Upgrade to PRO – 9.99 JD/month",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
