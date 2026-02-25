import '../../offers/models/offer_model.dart';

// 🎯 Claim Status Enum
enum ClaimStatus {
  ACTIVE,
  REDEEMED,
  EXPIRED;

  static ClaimStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return ClaimStatus.ACTIVE;
      case 'REDEEMED':
        return ClaimStatus.REDEEMED;
      case 'EXPIRED':
        return ClaimStatus.EXPIRED;
      default:
        return ClaimStatus.ACTIVE;
    }
  }

  String toDisplayString() {
    switch (this) {
      case ClaimStatus.ACTIVE:
        return 'Active';
      case ClaimStatus.REDEEMED:
        return 'Redeemed';
      case ClaimStatus.EXPIRED:
        return 'Expired';
    }
  }
}

// 🎯 User Offer Claim Model
class Claim {
  final String id;
  final String userId;
  final String offerId;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime? redeemedAt;
  final Offer offer;

  Claim({
    required this.id,
    required this.userId,
    required this.offerId,
    required this.status,
    required this.createdAt,
    this.redeemedAt,
    required this.offer,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      offerId: json['offerId'] ?? '',
      status: ClaimStatus.fromString(json['status'] ?? 'ACTIVE'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.parse(json['redeemedAt'])
          : null,
      offer: Offer.fromJson(json['offer'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'offerId': offerId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      if (redeemedAt != null) 'redeemedAt': redeemedAt!.toIso8601String(),
      'offer': offer.toJson(),
    };
  }

  bool get isActive => status == ClaimStatus.ACTIVE;
  bool get isRedeemed => status == ClaimStatus.REDEEMED;
  bool get isExpired => status == ClaimStatus.EXPIRED;
}
