// lib/providers/rewards_provider.dart

import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

class RedeemedCoupon {
  final String id;
  final String couponCode;
  final String storeName;
  final String discount;
  final int pointsCost;
  final DateTime redeemedAt;
  final DateTime expiresAt;

  const RedeemedCoupon({
    required this.id,
    required this.couponCode,
    required this.storeName,
    required this.discount,
    required this.pointsCost,
    required this.redeemedAt,
    required this.expiresAt,
  });

  factory RedeemedCoupon.fromAppwrite(Map<String, dynamic> json) {
    return RedeemedCoupon(
      id: json[r'$id'] as String,
      couponCode: json['couponCode'] as String,
      storeName: json['storeName'] as String,
      discount: json['discount'] as String,
      pointsCost: json['pointsCost'] as int,
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

class RewardsNotifier extends AsyncNotifier<List<RedeemedCoupon>> {
  @override
  Future<List<RedeemedCoupon>> build() async {
    ref.watch(authProvider);
    return _fetchAll();
  }

  Future<List<RedeemedCoupon>> _fetchAll() async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    if (user == null) return [];

    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.rewardsTableId,
        queries: [
          Query.equal('ownerId', user.$id),
          Query.orderDesc('redeemedAt'),
        ],
      );

      return result.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data[r'$id'] = doc.$id;
        return RedeemedCoupon.fromAppwrite(data);
      }).toList();
    } catch (e) {
      print('Error fetching rewards: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAll);
  }

  Future<void> redeemCoupon({
    required String storeName,
    required String discount,
    required int pointsCost,
    required int expiryDays,
  }) async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    if (user == null) throw Exception('Not logged in');

    // Check user still has enough points (fresh from DB)
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) throw Exception('Profile not loaded');
    if (profile.points < pointsCost) {
      throw Exception('Not enough Seeds');
    }

    final now = DateTime.now();
    final code = _generateCode(storeName);

    // 1. Save coupon to rewards collection
    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.rewardsTableId,
      documentId: ID.unique(),
      data: {
        'ownerId': user.$id,
        'couponCode': code,
        'storeName': storeName,
        'discount': discount,
        'pointsCost': pointsCost,
        'redeemedAt': now.toIso8601String(),
        'expiresAt':
            now.add(Duration(days: expiryDays)).toIso8601String(),
      },
      permissions: [
        Permission.read(Role.user(user.$id)),
        Permission.update(Role.user(user.$id)),
        Permission.delete(Role.user(user.$id)),
      ],
    );

    // 2. Deduct points from user profile
    final newPoints = profile.points - pointsCost;
    await databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.userProfileTableId,
      documentId: user.$id,
      data: {'points': newPoints},
    );

    // 3. Refresh both providers
    await refresh();
    await ref.read(userProfileProvider.notifier).refresh();
  }

  String _generateCode(String storeName) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    final prefix = storeName
        .replaceAll(' ', '')
        .toUpperCase()
        .substring(0, storeName.length.clamp(0, 3));
    final suffix =
        List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
    return '$prefix-$suffix';
  }
}

final rewardsProvider =
    AsyncNotifierProvider<RewardsNotifier, List<RedeemedCoupon>>(
        RewardsNotifier.new);
