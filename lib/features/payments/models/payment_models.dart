enum PromotionTier {
  silver,
  gold,
  platinum,
}

class PromotionPlan {
  final PromotionTier tier;
  final int days;
  final double price;
  final int weight;
  final String displayName;
  final String description;

  const PromotionPlan({
    required this.tier,
    required this.days,
    required this.price,
    required this.weight,
    required this.displayName,
    required this.description,
  });

  // 🇯🇴 Jordan Pricing (Backend-Controlled)
  static const List<PromotionPlan> plans = [
    PromotionPlan(
      tier: PromotionTier.silver,
      days: 3,
      price: 4.0,
      weight: 5,
      displayName: 'Silver',
      description: '3 days boost',
    ),
    PromotionPlan(
      tier: PromotionTier.gold,
      days: 7,
      price: 8.0,
      weight: 15,
      displayName: 'Gold',
      description: '7 days boost',
    ),
    PromotionPlan(
      tier: PromotionTier.platinum,
      days: 14,
      price: 13.0,
      weight: 30,
      displayName: 'Platinum',
      description: '14 days boost',
    ),
  ];

  String getTierString() {
    switch (tier) {
      case PromotionTier.silver:
        return 'SILVER';
      case PromotionTier.gold:
        return 'GOLD';
      case PromotionTier.platinum:
        return 'PLATINUM';
    }
  }
}

class PaymentRequest {
  final String offerId;
  final String tier;

  PaymentRequest({
    required this.offerId,
    required this.tier,
  });

  Map<String, dynamic> toJson() {
    return {
      'offerId': offerId,
      'tier': tier,
    };
  }
}

class PaymentResponse {
  final String paymentUrl;
  final String? paymentId;

  PaymentResponse({
    required this.paymentUrl,
    this.paymentId,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentUrl: json['paymentUrl'],
      paymentId: json['paymentId'],
    );
  }
}

class PaymentHistory {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String? tier;
  final DateTime createdAt;
  final PaymentOffer? offer;

  PaymentHistory({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.tier,
    required this.createdAt,
    this.offer,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'JOD',
      status: json['status'],
      tier: json['tier'],
      createdAt: DateTime.parse(json['createdAt']),
      offer: json['offer'] != null
          ? PaymentOffer.fromJson(json['offer'])
          : null,
    );
  }
}

class PaymentOffer {
  final String id;
  final String title;
  final String imageUrl;

  PaymentOffer({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory PaymentOffer.fromJson(Map<String, dynamic> json) {
    return PaymentOffer(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
    );
  }
}
