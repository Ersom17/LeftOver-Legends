// lib/providers/user_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/region_provider.dart';
import '../providers/user_settings_provider.dart';

class UserProfile {
  final String ownerId;
  final String country;
  final int points;
  final double totalSpent;
  final double totalWasted;

  const UserProfile({
    required this.ownerId,
    required this.country,
    required this.points,
    required this.totalSpent,
    required this.totalWasted,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      ownerId: json['ownerId'] as String? ?? '',
      country: json['country'] as String? ?? 'Switzerland',
      points: json['points'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalWasted: (json['totalWasted'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final authState = ref.watch(authProvider);
    if (!authState.hasValue || authState.value == null) return null;
    return _fetch(authState.value!.$id);
  }

  Future<UserProfile?> _fetch(String userId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
      );
      final profile = UserProfile.fromJson(doc.data);
      Future.microtask(() {
        ref.read(userCountryProvider.notifier).state = profile.country;
        // Keep region (used by date formatter, Rewards, Learn) in sync with
        // the country picked at register time / from Profile settings.
        ref.read(regionProvider.notifier).setRegionFromCountry(profile.country);
      });
      return profile;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> refresh() async {
    final authState = ref.read(authProvider);
    if (!authState.hasValue || authState.value == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(authState.value!.$id));
  }

  Future<void> updateCountry(String country) async {
    final authState = ref.read(authProvider);
    if (!authState.hasValue || authState.value == null) return;
    final userId = authState.value!.$id;
    try {
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
        data: {'country': country},
      );
      ref.read(userCountryProvider.notifier).state = country;
      await ref.read(regionProvider.notifier).setRegionFromCountry(country);
      await refresh();
    } catch (e) {
      print('Error updating country: $e');
      rethrow;
    }
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
        UserProfileNotifier.new);
