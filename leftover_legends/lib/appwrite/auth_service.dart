import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'appwrite_client.dart';

class AuthService {
  Future<models.User> getCurrentUser() async {
    return await account.get();
  }

  Future<models.User> login({
    required String email,
    required String password,
  }) async {
    await account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    return await account.get();
  }

  Future<models.User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );

    await account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    return await account.get();
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }
}