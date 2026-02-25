import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'ad_model.freezed.dart';
part 'ad_model.g.dart';

enum AdPlacement {
  HERO,
  HOME_FEED,
  SIDEBAR,
  POPUP,
}

@freezed
abstract class AdModel with _$AdModel {
  const factory AdModel({
    required String id,
    required String title,
    required String imageUrl,
    required String redirectUrl,
    required AdPlacement placement,
    String? cityId,
    required bool isActive,
    required DateTime startDate,
    required DateTime endDate,
    required int priority,
    required int clicks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AdModel;

  factory AdModel.fromJson(Map<String, dynamic> json) => _$AdModelFromJson(json);

  factory AdModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      redirectUrl: data['redirectUrl'] ?? '',
      placement: AdPlacement.values.firstWhere(
        (e) => e.toString().split('.').last == data['placement'],
        orElse: () => AdPlacement.HOME_FEED,
      ),
      cityId: data['cityId'],
      isActive: data['isActive'] ?? true,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: data['priority'] ?? 0,
      clicks: data['clicks'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}