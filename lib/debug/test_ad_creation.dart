import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../shared/services/firebase_ad_service.dart';
import '../shared/models/ad_model.dart';
import '../features/ads/providers/ad_provider.dart';

class TestAdCreation extends ConsumerWidget {
  const TestAdCreation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Ad Creation')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _createTestAds(ref, context),
          child: const Text('Create Test Ads'),
        ),
      ),
    );
  }

  Future<void> _createTestAds(WidgetRef ref, BuildContext context) async {
    final adService = ref.read(firebaseAdServiceProvider);

    try {
      // Create a test hero ad
      await adService.createAd(
        title: 'Welcome to Oroud! 🎉',
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop',
        redirectUrl: 'https://oroud.app',
        placement: 'HERO',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        priority: 10,
      );

      // Create a test feed ad
      await adService.createAd(
        title: 'Special Deal Today!',
        imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=300&fit=crop',
        redirectUrl: 'https://oroud.app/deals',
        placement: 'HOME_FEED',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        priority: 5,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test ads created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create test ads: $e')),
      );
    }
  }
}