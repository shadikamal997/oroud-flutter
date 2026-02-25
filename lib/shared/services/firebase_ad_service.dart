import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class FirebaseAdService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference for ads
  CollectionReference get _adsCollection => _firestore.collection('ads');

  // Upload ad image to Firebase Storage
  Future<String> uploadAdImage(File imageFile, String adId) async {
    try {
      final fileName = '${adId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final storageRef = _storage.ref().child('ads/$fileName');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload ad image: $e');
    }
  }

  // Create new ad in Firestore
  Future<String> createAd({
    required String title,
    required String imageUrl,
    required String redirectUrl,
    required String placement,
    String? cityId,
    required DateTime startDate,
    required DateTime endDate,
    int priority = 0,
  }) async {
    try {
      final adData = {
        'title': title,
        'imageUrl': imageUrl,
        'redirectUrl': redirectUrl,
        'placement': placement,
        'cityId': cityId,
        'isActive': true,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'priority': priority,
        'clicks': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _adsCollection.add(adData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create ad: $e');
    }
  }

  // Get active ads for specific placement
  Stream<QuerySnapshot> getActiveAds({
    String? placement,
    String? cityId,
  }) {
    Query query = _adsCollection
        .where('isActive', isEqualTo: true)
        .where('startDate', isLessThanOrEqualTo: Timestamp.now())
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('startDate', descending: true)
        .orderBy('priority', descending: true)
        .limit(50);

    if (placement != null) {
      query = query.where('placement', isEqualTo: placement);
    }

    if (cityId != null) {
      query = query.where('cityId', isEqualTo: cityId);
    }

    return query.snapshots();
  }

  // Get hero ads (real-time stream)
  Stream<QuerySnapshot> getHeroAds({String? cityId}) {
    return getActiveAds(placement: 'HERO', cityId: cityId);
  }

  // Get feed ads (real-time stream)
  Stream<QuerySnapshot> getFeedAds({String? cityId}) {
    return getActiveAds(placement: 'HOME_FEED', cityId: cityId);
  }

  // Track ad click
  Future<void> trackAdClick(String adId) async {
    try {
      await _adsCollection.doc(adId).update({
        'clicks': FieldValue.increment(1),
      });
    } catch (e) {
      print('Failed to track ad click: $e');
    }
  }

  // Update ad
  Future<void> updateAd(String adId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _adsCollection.doc(adId).update(updates);
    } catch (e) {
      throw Exception('Failed to update ad: $e');
    }
  }

  // Delete ad
  Future<void> deleteAd(String adId) async {
    try {
      // Get ad data first to delete image
      final adDoc = await _adsCollection.doc(adId).get();
      if (adDoc.exists) {
        final adData = adDoc.data() as Map<String, dynamic>;
        final imageUrl = adData['imageUrl'];

        // Delete from Firestore
        await _adsCollection.doc(adId).delete();

        // Delete image from Storage if it's a Firebase Storage URL
        if (imageUrl != null && imageUrl.toString().contains('firebasestorage.googleapis.com')) {
          try {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            print('Failed to delete image from storage: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to delete ad: $e');
    }
  }

  // Get single ad by ID
  Future<DocumentSnapshot> getAdById(String adId) async {
    return await _adsCollection.doc(adId).get();
  }
}