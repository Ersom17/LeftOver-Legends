import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as models;
import '../appwrite/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthNotifier extends AsyncNotifier<models.User?> {
  @override
  Future<models.User?> build() async {
    try {
      return await ref.read(authServiceProvider).getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).login(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String country,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).register(
            name: name,
            email: email,
            password: password,
            country: country,
          ),
    );
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, models.User?>(AuthNotifier.new);
