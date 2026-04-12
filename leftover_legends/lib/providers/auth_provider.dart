import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as models;
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../appwrite/auth_service.dart';
import '../services/country_config_service.dart';
import 'user_settings_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthNotifier extends AsyncNotifier<models.User?> {
  @override
  Future<models.User?> build() async {
    try {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      // On app start, if already logged in, load country immediately
      await _loadUserCountry(user.$id);
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Fetches the user profile from Appwrite and sets userCountryProvider
  /// so all derived providers (currency, culture) are correct from the start.
  Future<void> _loadUserCountry(String userId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: userId,
      );
      final country = doc.data['country'] as String? ?? 'Switzerland';
      ref.read(userCountryProvider.notifier).state = country;
    } catch (e) {
      // If fetching fails, leave the default — not fatal
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authServiceProvider).login(
            email: email,
            password: password,
          );
      await _loadUserCountry(user.$id);
      return user;
    });
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String country,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authServiceProvider).register(
            name: name,
            email: email,
            password: password,
            country: country,
          );
      // For register we already know the country — set it immediately
      ref.read(userCountryProvider.notifier).state = country;
      return user;
    });
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    // Reset country to default on logout so the next user starts clean
    ref.read(userCountryProvider.notifier).state = 'Switzerland';
    state = const AsyncData(null);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, models.User?>(AuthNotifier.new);
