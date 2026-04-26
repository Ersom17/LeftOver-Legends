import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'appwrite_client.dart';
import 'appwrite_constants.dart';

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
    required String country,
  }) async {
    final userId = ID.unique();
    
    // 1. Create the user account
    await account.create(
      userId: userId,
      email: email,
      password: password,
      name: name,
    );

    // 2. Create the user profile in the database
    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.userProfileTableId,
      documentId: userId,
      data: {
        'ownerId': userId,
        'country': country,
        'points': 0,
        'totalSpent': 0.0,
        'totalWasted': 0,
      },
    );

    // 3. Create a session
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
