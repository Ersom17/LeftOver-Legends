// lib/providers/user_profile_provider.dart
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/user_settings_provider.dart';

class UserProfile {
  final String ownerId;
  final String country;
  final int points;
  final double totalSpent;
  final int totalWasted;

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
      totalWasted: json['totalWasted'] as int? ?? 0,
    );
  }
}

// Fetch user profile from database and update country setting
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authProvider);
  
  // If not authenticated, return null
  if (!authState.hasValue || authState.value == null) {
    return null;
  }

  final user = authState.value!;
  
  try {
    final doc = await databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.userProfileTableId,
      documentId: user.$id,
    );

    final profile = UserProfile.fromJson(doc.data);
    
    // Update the country setting in the provider
    Future.microtask(() {
      ref.read(userCountryProvider.notifier).state = profile.country;
    });

    return profile;
  } catch (e) {
    // Profile not found or error fetching it
    print('Error fetching user profile: $e');
    return null;
  }
});
