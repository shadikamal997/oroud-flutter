class ShopAnalytics {
  final int totalViews;
  final int totalSaves;
  final int totalClicks;
  final TopOffer? topOffer;
  final int boostedOffersCount;
  final int activeOffersCount;
  final int totalOffersCount;

  ShopAnalytics({
    required this.totalViews,
    required this.totalSaves,
    required this.totalClicks,
    this.topOffer,
    required this.boostedOffersCount,
    required this.activeOffersCount,
    required this.totalOffersCount,
  });

  factory ShopAnalytics.fromJson(Map<String, dynamic> json) {
    return ShopAnalytics(
      totalViews: json['totalViews'] ?? 0,
      totalSaves: json['totalSaves'] ?? 0,
      totalClicks: json['totalClicks'] ?? 0,
      topOffer: json['topOffer'] != null
          ? TopOffer.fromJson(json['topOffer'])
          : null,
      boostedOffersCount: json['boostedOffersCount'] ?? 0,
      activeOffersCount: json['activeOffersCount'] ?? 0,
      totalOffersCount: json['totalOffersCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalViews': totalViews,
      'totalSaves': totalSaves,
      'totalClicks': totalClicks,
      'topOffer': topOffer?.toJson(),
      'boostedOffersCount': boostedOffersCount,
      'activeOffersCount': activeOffersCount,
      'totalOffersCount': totalOffersCount,
    };
  }
}

class TopOffer {
  final String id;
  final String title;
  final String imageUrl;
  final int views;
  final int saves;
  final int clicks;
  final double discountPercentage;

  TopOffer({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.views,
    required this.saves,
    required this.clicks,
    required this.discountPercentage,
  });

  factory TopOffer.fromJson(Map<String, dynamic> json) {
    return TopOffer(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      views: json['views'] ?? 0,
      saves: json['saves'] ?? 0,
      clicks: json['clicks'] ?? 0,
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'views': views,
      'saves': saves,
      'clicks': clicks,
      'discountPercentage': discountPercentage,
    };
  }
}
