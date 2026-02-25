import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/ad_model.dart';
import '../../../shared/services/firebase_ad_service.dart';
import 'dart:io';

// Firebase Ad Service Provider
final firebaseAdServiceProvider = Provider<FirebaseAdService>((ref) {
  return FirebaseAdService();
});

// Hero Ads Stream Provider (real-time)
final heroAdsProvider = StreamProvider<List<AdModel>>((ref) {
  final adService = ref.watch(firebaseAdServiceProvider);
  return adService.getHeroAds().map((snapshot) {
    return snapshot.docs
        .map((doc) => AdModel.fromFirestore(doc))
        .toList();
  });
});

// Feed Ads Stream Provider (real-time)
final feedAdsProvider = StreamProvider<List<AdModel>>((ref) {
  final adService = ref.watch(firebaseAdServiceProvider);
  return adService.getFeedAds().map((snapshot) {
    return snapshot.docs
        .map((doc) => AdModel.fromFirestore(doc))
        .toList();
  });
});

// City-specific Hero Ads Provider
final cityHeroAdsProvider = StreamProvider.family<List<AdModel>, String?>((ref, cityId) {
  final adService = ref.watch(firebaseAdServiceProvider);
  return adService.getHeroAds(cityId: cityId).map((snapshot) {
    return snapshot.docs
        .map((doc) => AdModel.fromFirestore(doc))
        .toList();
  });
});

// City-specific Feed Ads Provider
final cityFeedAdsProvider = StreamProvider.family<List<AdModel>, String?>((ref, cityId) {
  final adService = ref.watch(firebaseAdServiceProvider);
  return adService.getFeedAds(cityId: cityId).map((snapshot) {
    return snapshot.docs
        .map((doc) => AdModel.fromFirestore(doc))
        .toList();
  });
});

// Ad Actions Provider
final adActionsProvider = Provider<AdActions>((ref) {
  final adService = ref.watch(firebaseAdServiceProvider);
  return AdActions(adService);
});

class AdActions {
  final FirebaseAdService _adService;

  AdActions(this._adService);

  // Create ad with image upload
  Future<String> createAd({
    required String title,
    required File imageFile,
    required String redirectUrl,
    required AdPlacement placement,
    String? cityId,
    required DateTime startDate,
    required DateTime endDate,
    int priority = 0,
  }) async {
    try {
      // First upload image
      final adId = 'ad_${DateTime.now().millisecondsSinceEpoch}';
      final imageUrl = await _adService.uploadAdImage(imageFile, adId);

      // Then create ad document
      final docId = await _adService.createAd(
        title: title,
        imageUrl: imageUrl,
        redirectUrl: redirectUrl,
        placement: placement.toString().split('.').last,
        cityId: cityId,
        startDate: startDate,
        endDate: endDate,
        priority: priority,
      );

      return docId;
    } catch (e) {
      throw Exception('Failed to create ad: $e');
    }
  }

  // Track ad click
  Future<void> trackAdClick(String adId) async {
    await _adService.trackAdClick(adId);
  }

  // Update ad
  Future<void> updateAd(String adId, Map<String, dynamic> updates) async {
    await _adService.updateAd(adId, updates);
  }

  // Delete ad
  Future<void> deleteAd(String adId) async {
    await _adService.deleteAd(adId);
  }
}