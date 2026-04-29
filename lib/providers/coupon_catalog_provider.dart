// lib/providers/coupon_catalog_provider.dart
//
// Reads the admin-managed coupon catalog from Appwrite, filtered to the
// active region. The screen still renders sections, so the provider
// returns the whole list and the UI groups by [CouponSpec.section].
//
// If the network call fails or the catalog is empty, we fall back to a
// hardcoded seed list so the Rewards tab is never blank during a demo.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/coupon_spec.dart';
import '../repositories/appwrite_coupon_catalog_repository.dart';
import '../theme/app_theme.dart';
import 'region_provider.dart';

class CouponCatalogNotifier extends AsyncNotifier<List<CouponSpec>> {
  @override
  Future<List<CouponSpec>> build() async {
    final region = ref.watch(regionProvider);
    final regionStr = region == AppRegion.us ? 'us' : 'europe';

    try {
      final repo = AppwriteCouponCatalogRepository();
      final list = await repo.getForRegion(regionStr);
      if (list.isNotEmpty) return list;
      // Server returned no rows for this region — show the seed so the
      // demo still has something to display.
      return _seed(regionStr);
    } catch (_) {
      return _seed(regionStr);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final couponCatalogProvider =
    AsyncNotifierProvider<CouponCatalogNotifier, List<CouponSpec>>(
        CouponCatalogNotifier.new);

// ─── Local seed (fallback only) ──────────────────────────────────────────────
//
// Mirrors the original hardcoded catalog so a fresh Appwrite project (or
// a temporary network failure) still renders a populated Rewards tab.
// Once the admin has seeded coupon_catalog with real data, this code path
// stops being hit.

List<CouponSpec> _seed(String region) {
  if (region == 'us') return _usSeed;
  return _euSeed;
}

CouponSpec _stub({
  required String store,
  required String emoji,
  required Color color,
  required String discount,
  required String description,
  required int pointsCost,
  required int expiryDays,
  required CouponSection section,
  required int sortOrder,
  required String region,
}) {
  return CouponSpec(
    docId: 'seed-$region-${section.id}-$sortOrder',
    store: store,
    emoji: emoji,
    color: color,
    discount: discount,
    description: description,
    pointsCost: pointsCost,
    expiryDays: expiryDays,
    section: section,
    sortOrder: sortOrder,
    active: true,
    region: region,
  );
}

final List<CouponSpec> _euSeed = [
  // Supermarkets
  _stub(
    store: 'Migros',
    emoji: '🛍️',
    color: AppColors.warn,
    discount: '5% off your next shop',
    description: 'Valid on any purchase over CHF 30',
    pointsCost: 20,
    expiryDays: 30,
    section: CouponSection.supermarkets,
    sortOrder: 10,
    region: 'europe',
  ),
  _stub(
    store: 'Coop',
    emoji: '🏪',
    color: AppColors.danger,
    discount: '10% off fresh produce',
    description: 'Valid on fruits, vegetables & dairy',
    pointsCost: 35,
    expiryDays: 21,
    section: CouponSection.supermarkets,
    sortOrder: 20,
    region: 'europe',
  ),
  _stub(
    store: 'Denner',
    emoji: '🍷',
    color: AppColors.warmGold,
    discount: 'CHF 5 off wines',
    description: 'Valid on any bottle over CHF 12',
    pointsCost: 25,
    expiryDays: 14,
    section: CouponSection.supermarkets,
    sortOrder: 30,
    region: 'europe',
  ),
  _stub(
    store: 'Aldi Suisse',
    emoji: '🛒',
    color: AppColors.mutedOlive,
    discount: '10% off entire basket',
    description: 'Min CHF 25, in-store only',
    pointsCost: 30,
    expiryDays: 21,
    section: CouponSection.supermarkets,
    sortOrder: 40,
    region: 'europe',
  ),
  _stub(
    store: 'Lidl',
    emoji: '🥬',
    color: AppColors.good,
    discount: 'CHF 3 off CHF 20',
    description: 'Valid on weekday shops',
    pointsCost: 18,
    expiryDays: 14,
    section: CouponSection.supermarkets,
    sortOrder: 50,
    region: 'europe',
  ),
  // Restaurants
  _stub(
    store: 'Nordsee',
    emoji: '🐟',
    color: AppColors.mutedOlive,
    discount: '15% off any meal',
    description: 'Valid Mon–Thu, dine-in only',
    pointsCost: 50,
    expiryDays: 60,
    section: CouponSection.restaurants,
    sortOrder: 10,
    region: 'europe',
  ),
  _stub(
    store: 'Pizza Hut',
    emoji: '🍕',
    color: AppColors.danger,
    discount: 'Buy 1 get 1 free pizza',
    description: 'Valid on medium or large pizzas',
    pointsCost: 80,
    expiryDays: 30,
    section: CouponSection.restaurants,
    sortOrder: 20,
    region: 'europe',
  ),
  _stub(
    store: 'Starbucks',
    emoji: '☕',
    color: AppColors.good,
    discount: 'Free size upgrade',
    description: 'Upgrade any drink to the next size',
    pointsCost: 15,
    expiryDays: 14,
    section: CouponSection.restaurants,
    sortOrder: 30,
    region: 'europe',
  ),
  // Eco
  _stub(
    store: 'Alnatura',
    emoji: '🌿',
    color: AppColors.darkGreen,
    discount: '10% off entire basket',
    description: 'Organic products only, min CHF 20',
    pointsCost: 40,
    expiryDays: 30,
    section: CouponSection.eco,
    sortOrder: 10,
    region: 'europe',
  ),
  _stub(
    store: 'Too Good To Go',
    emoji: '♻️',
    color: AppColors.good,
    discount: 'CHF 3 off a magic bag',
    description: 'Rescue food, save money',
    pointsCost: 10,
    expiryDays: 7,
    section: CouponSection.eco,
    sortOrder: 20,
    region: 'europe',
  ),
];

final List<CouponSpec> _usSeed = [
  // Supermarkets
  _stub(
    store: 'Walmart',
    emoji: '🛒',
    color: AppColors.warn,
    discount: '\$5 off \$40 grocery order',
    description: 'In-store or pickup, exclusions apply',
    pointsCost: 25,
    expiryDays: 30,
    section: CouponSection.supermarkets,
    sortOrder: 10,
    region: 'us',
  ),
  _stub(
    store: 'Wegmans',
    emoji: '🥗',
    color: AppColors.darkGreen,
    discount: '10% off fresh produce',
    description: 'Valid on fruits, vegetables & deli',
    pointsCost: 35,
    expiryDays: 21,
    section: CouponSection.supermarkets,
    sortOrder: 20,
    region: 'us',
  ),
  _stub(
    store: 'Trader Joe\'s',
    emoji: '🥑',
    color: AppColors.danger,
    discount: '\$5 off \$30',
    description: 'In-store, one per customer',
    pointsCost: 30,
    expiryDays: 21,
    section: CouponSection.supermarkets,
    sortOrder: 30,
    region: 'us',
  ),
  _stub(
    store: 'Whole Foods',
    emoji: '🥦',
    color: AppColors.good,
    discount: '15% off organic produce',
    description: 'Prime members only, weekly limit',
    pointsCost: 45,
    expiryDays: 14,
    section: CouponSection.supermarkets,
    sortOrder: 40,
    region: 'us',
  ),
  _stub(
    store: 'Kroger',
    emoji: '🏪',
    color: AppColors.mutedOlive,
    discount: '\$3 off \$25',
    description: 'In-store, exclusions apply',
    pointsCost: 18,
    expiryDays: 21,
    section: CouponSection.supermarkets,
    sortOrder: 50,
    region: 'us',
  ),
  // Restaurants
  _stub(
    store: 'Chipotle',
    emoji: '🌯',
    color: AppColors.warmGold,
    discount: 'Free guacamole add-on',
    description: 'On any entrée, in-app or in-store',
    pointsCost: 20,
    expiryDays: 30,
    section: CouponSection.restaurants,
    sortOrder: 10,
    region: 'us',
  ),
  _stub(
    store: 'Starbucks',
    emoji: '☕',
    color: AppColors.good,
    discount: 'Free size upgrade',
    description: 'Upgrade any drink to the next size',
    pointsCost: 15,
    expiryDays: 14,
    section: CouponSection.restaurants,
    sortOrder: 20,
    region: 'us',
  ),
  _stub(
    store: 'Panera',
    emoji: '🥖',
    color: AppColors.mutedOlive,
    discount: '\$3 off any soup & sandwich',
    description: 'Valid Mon–Fri, in-app order',
    pointsCost: 25,
    expiryDays: 30,
    section: CouponSection.restaurants,
    sortOrder: 30,
    region: 'us',
  ),
  // Eco
  _stub(
    store: 'Imperfect Foods',
    emoji: '🥕',
    color: AppColors.darkGreen,
    discount: '\$10 off first box',
    description: 'Rescued produce delivered to your door',
    pointsCost: 30,
    expiryDays: 30,
    section: CouponSection.eco,
    sortOrder: 10,
    region: 'us',
  ),
  _stub(
    store: 'Too Good To Go',
    emoji: '♻️',
    color: AppColors.good,
    discount: '\$3 off a Surprise Bag',
    description: 'Rescue food, save money',
    pointsCost: 10,
    expiryDays: 7,
    section: CouponSection.eco,
    sortOrder: 20,
    region: 'us',
  ),
  _stub(
    store: 'Misfits Market',
    emoji: '🥦',
    color: AppColors.warn,
    discount: '20% off your first order',
    description: 'Organic groceries shipped nationwide',
    pointsCost: 35,
    expiryDays: 21,
    section: CouponSection.eco,
    sortOrder: 30,
    region: 'us',
  ),
];
