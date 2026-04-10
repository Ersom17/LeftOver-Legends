import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_client.dart';
import '../appwrite/appwrite_constants.dart';
import '../models/item.dart';
import 'item_repository.dart';

class AppwriteItemRepository implements ItemRepository {
  final String ownerId;

  AppwriteItemRepository(this.ownerId);

  @override
  Future<List<FridgeItem>> getAll() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      queries: [
        Query.equal('ownerId', ownerId),
        Query.orderAsc('expirationDate'),
      ],
    );

    return result.documents.map((doc) {
      final data = Map<String, dynamic>.from(doc.data);
      data[r'$id'] = doc.$id;
      data[r'$createdAt'] = doc.$createdAt;
      return FridgeItem.fromAppwrite(data);
    }).toList();
  }

  @override
  Future<void> add(FridgeItem item) async {
    // Create the item
    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      documentId: ID.unique(),
      data: item.toAppwriteMap(),
      permissions: [
        Permission.read(Role.user(item.ownerId)),
        Permission.update(Role.user(item.ownerId)),
        Permission.delete(Role.user(item.ownerId)),
      ],
    );

    // Update user profile: add price to totalSpent
    await _updateUserProfile(
      ownerId: item.ownerId,
      spentAmount: item.price ?? 0.0,
      wastedAmount: 0.0,
    );
  }

  @override
  Future<void> delete(String id) async {
    await databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      documentId: id,
    );
  }

  @override
  Future<void> update(FridgeItem item) async {
    await databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.itemsTableId,
      documentId: item.id,
      data: item.toAppwriteMap(),
    );
  }

  /// Mark item as thrown away and update totalWasted
  Future<void> markAsWaste(FridgeItem item) async {
    // Delete the item
    await delete(item.id);

    // Update user profile: add price to totalWasted
    await _updateUserProfile(
      ownerId: item.ownerId,
      spentAmount: 0.0,
      wastedAmount: item.price ?? 0.0,
    );
  }

  /// Mark item as consumed (just delete, no waste tracking, but add 1 point)
  Future<void> markAsConsumed(FridgeItem item) async {
    // Delete the item
    await delete(item.id);

    // Update user profile: add 1 point
    await _updateUserProfilePoints(
      ownerId: item.ownerId,
      pointsToAdd: 1,
    );
  }

  /// Helper method to update user profile with spending/waste amounts
  Future<void> _updateUserProfile({
    required String ownerId,
    required double spentAmount,
    required double wastedAmount,
  }) async {
    try {
      // Fetch current profile
      final profile = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: ownerId,
      );

      final currentSpent = (profile.data['totalSpent'] as num?)?.toDouble() ?? 0.0;
      final currentWasted = (profile.data['totalWasted'] as num?)?.toDouble() ?? 0.0;

      // Update with new amounts
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: ownerId,
        data: {
          'totalSpent': currentSpent + spentAmount,
          'totalWasted': currentWasted + wastedAmount,
        },
      );
    } catch (e) {
      print('Error updating user profile: $e');
      // Don't throw, just log - item was already added/deleted
    }
  }

  /// Helper method to add points to user profile
  Future<void> _updateUserProfilePoints({
    required String ownerId,
    required int pointsToAdd,
  }) async {
    try {
      // Fetch current profile
      final profile = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: ownerId,
      );

      final currentPoints = (profile.data['points'] as num?)?.toInt() ?? 0;

      // Update with new points
      await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.userProfileTableId,
        documentId: ownerId,
        data: {
          'points': currentPoints + pointsToAdd,
        },
      );
    } catch (e) {
      print('Error updating user points: $e');
      // Don't throw, just log - item was already deleted
    }
  }

}
