// lib/models/coupon_spec.dart
//
// Coupon catalog entry. Used to be a private record inside
// rewards_screen.dart; promoted to a model now that the catalog comes
// from Appwrite instead of being hardcoded.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum CouponSection {
  supermarkets,
  restaurants,
  eco;

  String get id {
    switch (this) {
      case CouponSection.supermarkets:
        return 'supermarkets';
      case CouponSection.restaurants:
        return 'restaurants';
      case CouponSection.eco:
        return 'eco';
    }
  }

  static CouponSection fromString(String? value) {
    switch (value) {
      case 'restaurants':
        return CouponSection.restaurants;
      case 'eco':
        return CouponSection.eco;
      case 'supermarkets':
      default:
        return CouponSection.supermarkets;
    }
  }
}

class CouponSpec {
  /// Appwrite document id, kept for ordering / debugging.
  final String docId;
  final String store;
  final String emoji;
  final Color color;
  final String discount;
  final String description;
  final int pointsCost;
  final int expiryDays;
  final CouponSection section;
  final int sortOrder;
  final bool active;

  /// `'us'` or `'europe'`.
  final String region;

  const CouponSpec({
    required this.docId,
    required this.store,
    required this.emoji,
    required this.color,
    required this.discount,
    required this.description,
    required this.pointsCost,
    required this.expiryDays,
    required this.section,
    required this.sortOrder,
    required this.active,
    required this.region,
  });

  factory CouponSpec.fromAppwrite(Map<String, dynamic> json, String docId) {
    return CouponSpec(
      docId: docId,
      store: json['store'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🏷️',
      color: _colorFromHex(json['colorHex'] as String?),
      discount: json['discount'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      expiryDays: (json['expiryDays'] as num?)?.toInt() ?? 30,
      section: CouponSection.fromString(json['section'] as String?),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      region: (json['region'] as String? ?? 'europe').toLowerCase(),
    );
  }

  static Color _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.darkGreen;
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final value = int.tryParse(h, radix: 16);
    if (value == null) return AppColors.darkGreen;
    return Color(value);
  }
}
